# Runtime-test iteration: reuse the existing APK artifact.
#!/usr/bin/env python3
"""Black-box Android UI smoke test for NRave.

Uses only adb + Android UIAutomator's hierarchy dump, so the test runs inside
GitHub's Android emulator without third-party Python packages.
"""

from __future__ import annotations

import os
import re
import subprocess
import sys
import time
import xml.etree.ElementTree as ET
import hashlib
from pathlib import Path
from typing import Callable

ADB = os.environ.get("ADB", "adb")
APK = Path(os.environ.get(
    "NRAVE_APK",
    "runtime-apk/android-build-release-signed.apk",
))
WORKSPACE = Path(os.environ.get("GITHUB_WORKSPACE", "."))
DIAG = WORKSPACE / "nrave-ui-test-diagnostics"
DIAG.mkdir(parents=True, exist_ok=True)


class UiTestError(RuntimeError):
    pass


def run_adb(*args: str, timeout: int = 60, check: bool = True) -> str:
    cmd = [ADB, *args]
    proc = subprocess.run(
        cmd,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=timeout,
    )
    if check and proc.returncode != 0:
        raise UiTestError(
            f"ADB command failed ({proc.returncode}): {' '.join(cmd)}\n"
            f"{proc.stdout}"
        )
    return proc.stdout


def run_shell(*args: str, timeout: int = 60, check: bool = True) -> str:
    return run_adb("shell", *args, timeout=timeout, check=check)


def screenshot(name: str) -> None:
    target = DIAG / name
    with target.open("wb") as fh:
        proc = subprocess.run(
            [ADB, "exec-out", "screencap", "-p"],
            stdout=fh,
            stderr=subprocess.PIPE,
            timeout=30,
        )
    if proc.returncode != 0:
        raise UiTestError(
            f"Could not capture screenshot: {proc.stderr.decode(errors='replace')}"
        )


def save_logcat(name: str = "logcat.txt") -> str:
    data = run_adb("logcat", "-d", timeout=30)
    (DIAG / name).write_text(data, encoding="utf-8")
    return data


def assert_no_fatal(logcat: str) -> None:
    patterns = (
        r"FATAL EXCEPTION",
        r"AndroidRuntime:\s*FATAL",
        r"Fatal signal\s+\d+",
        r"SIGSEGV",
        r"SIGABRT",
    )
    for pattern in patterns:
        if re.search(pattern, logcat, flags=re.IGNORECASE):
            raise UiTestError(f"Fatal runtime signature found in logcat: {pattern}")


def wait_until(
    predicate: Callable[[], object],
    description: str,
    timeout: float = 60.0,
    interval: float = 1.0,
):
    deadline = time.time() + timeout
    last_error: Exception | None = None
    while time.time() < deadline:
        try:
            value = predicate()
            if value:
                return value
        except Exception as exc:  # noqa: BLE001
            last_error = exc
        time.sleep(interval)
    detail = f"; last error: {last_error}" if last_error else ""
    raise UiTestError(f"Timed out waiting for {description}{detail}")


def dump_ui() -> ET.Element:
    run_shell(
        "uiautomator",
        "dump",
        "/sdcard/window.xml",
        timeout=30,
        check=False,
    )
    xml = run_adb("exec-out", "cat", "/sdcard/window.xml", timeout=30)
    if not xml.strip().startswith("<?xml") and "<hierarchy" not in xml:
        raise UiTestError(f"UIAutomator returned invalid XML:\n{xml[:1000]}")
    (DIAG / "last-window.xml").write_text(xml, encoding="utf-8")
    try:
        return ET.fromstring(xml)
    except ET.ParseError as exc:
        raise UiTestError(f"Could not parse UI hierarchy: {exc}") from exc


def all_nodes(root: ET.Element):
    return list(root.iter("node"))


def node_matches(node: ET.Element, value: str, fields=("text", "content-desc", "resource-id")) -> bool:
    value_norm = value.casefold()
    for field in fields:
        actual = node.attrib.get(field, "")
        if actual and value_norm in actual.casefold():
            return True
    return False


def find_nodes(value: str, exact: bool = False):
    root = dump_ui()
    result = []
    for node in all_nodes(root):
        fields = ("text", "content-desc", "resource-id")
        for field in fields:
            actual = node.attrib.get(field, "")
            if not actual:
                continue
            ok = actual.casefold() == value.casefold() if exact else value.casefold() in actual.casefold()
            if ok:
                result.append(node)
                break
    return result


def bounds(node: ET.Element) -> tuple[int, int, int, int]:
    raw = node.attrib.get("bounds", "")
    match = re.fullmatch(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]", raw)
    if not match:
        raise UiTestError(f"Node has no usable bounds: {node.attrib}")
    return tuple(map(int, match.groups()))


def click_node(node: ET.Element) -> None:
    x1, y1, x2, y2 = bounds(node)
    x = (x1 + x2) // 2
    y = (y1 + y2) // 2
    run_shell("input", "tap", str(x), str(y), timeout=10)


def click_value(value: str, *, exact: bool = False, occurrence: int = 0) -> ET.Element:
    nodes = find_nodes(value, exact=exact)
    if len(nodes) <= occurrence:
        raise UiTestError(
            f"Could not find UI element {value!r} occurrence={occurrence}; "
            f"available matches={len(nodes)}"
        )
    node = nodes[occurrence]
    if node.attrib.get("enabled", "true").casefold() == "false":
        raise UiTestError(f"UI element {value!r} is disabled: {node.attrib}")
    click_node(node)
    return node


def physical_screen_size() -> tuple[int, int]:
    output = run_shell("wm", "size", timeout=10)
    match = re.search(r"(\d+)x(\d+)", output)
    if not match:
        raise UiTestError(f"Could not determine physical screen size: {output!r}")
    return int(match.group(1)), int(match.group(2))


def app_window_bounds() -> tuple[int, int, int, int] | None:
    output = run_shell("dumpsys", "window", "windows", timeout=15, check=False)
    # Android's window dump normally exposes the application frame as
    # mFrame=Rect(left,top - right,bottom). The physical display can be much
    # wider than the Qt window on this emulator, so screen width is not a safe
    # Settings-button coordinate.
    for line in output.splitlines():
        if "org.mixxx/org.mixxx.MainActivity" not in line:
            continue
        match = re.search(
            r"mFrame=Rect\((-?\d+),(-?\d+) - (-?\d+),(-?\d+)\)",
            line,
        )
        if match:
            return tuple(map(int, match.groups()))
    return None


def click_settings_button() -> None:
    # The Settings control is an icon-only gear. Qt Quick accessibility is not
    # guaranteed to appear in Android UIAutomator. Clear Android system
    # overlays first, then use semantic lookup and finally app-window geometry.
    dismiss_android_system_overlays(timeout=5)
    for value in ("nrave_settings_button", "Settings"):
        nodes = find_nodes(value, exact=True)
        if nodes:
            node = nodes[0]
            if node.attrib.get("enabled", "true").casefold() != "false":
                click_node(node)
                return

    frame = app_window_bounds()
    if frame:
        left, top, right, _ = frame
        run_shell("input", "tap", str(right - 38), str(top + 18), timeout=10)
        return

    # Last-resort fallback for unusual Android window dumps.
    width, _ = physical_screen_size()
    run_shell("input", "tap", str(width - 38), "18", timeout=10)


def reopen_settings() -> None:
    # Settings is an icon-only gear, therefore never depend on visible button
    # text for reopening it.
    before = screen_hash()
    click_settings_button()
    wait_for_screen_change(before, timeout=8)


def screen_hash() -> str:
    data = subprocess.check_output([ADB, "exec-out", "screencap", "-p"], timeout=30)
    return hashlib.sha256(data).hexdigest()


def wait_for_screen_change(previous_hash: str, timeout: float = 8.0) -> None:
    wait_until(
        lambda: screen_hash() != previous_hash,
        "Android screen change",
        timeout=timeout,
        interval=0.5,
    )


def settings_geometry() -> tuple[int, int, int, int]:
    width, height = physical_screen_size()
    popup_width = min(1400, width)
    popup_height = min(840, height)
    popup_x = round((width - popup_width) / 2)
    popup_y = round((height - popup_height) / 2)
    return popup_x, popup_y, popup_width, popup_height


def click_interface_category() -> None:
    popup_x, popup_y, _, _ = settings_geometry()
    # Settings.qml: 20px popup padding + 280px sidebar. The category list
    # starts after Back (34), separator (1), and Search (30). Interface is
    # category index 3 with 38px rows.
    x = popup_x + 20 + 140
    y = popup_y + 85 + 3 * 38 + 19
    run_shell("input", "tap", str(x), str(y), timeout=10)


def select_latenight_skin() -> None:
    popup_x, popup_y, popup_width, popup_height = settings_geometry()
    # Interface.qml puts the Skin ComboBox on the first Theme & Color row.
    # The control sits at the right edge of the settings content.
    x = popup_x + popup_width - 80
    y = popup_y + 20 + 36 + 32 + 30 + 20 + 18
    run_shell("input", "tap", str(x), str(y), timeout=10)
    time.sleep(0.5)
    run_shell("input", "keyevent", "KEYCODE_DPAD_DOWN", timeout=10)
    run_shell("input", "keyevent", "KEYCODE_ENTER", timeout=10)


def close_settings() -> None:
    popup_x, popup_y, _, _ = settings_geometry()
    x = popup_x + 160
    y = popup_y + 20 + 17
    run_shell("input", "tap", str(x), str(y), timeout=10)


def save_settings() -> None:
    popup_x, popup_y, popup_width, popup_height = settings_geometry()
    x = popup_x + popup_width - 45
    y = popup_y + popup_height - 10
    run_shell("input", "tap", str(x), str(y), timeout=10)


def wait_for_any_value(values: tuple[str, ...], timeout: float = 30) -> str:
    def predicate():
        for value in values:
            if find_nodes(value, exact=True):
                return value
        return None

    result = wait_until(predicate, f"one of {values!r}", timeout=timeout)
    return str(result)


def wait_for_value(value: str, timeout: float = 30, exact: bool = False) -> ET.Element:
    return wait_until(
        lambda: (find_nodes(value, exact=exact) or [None])[0],
        f"UI element {value!r}",
        timeout=timeout,
    )


def wait_for_process(timeout: float = 60) -> None:
    wait_until(
        lambda: bool(run_shell("pidof", "org.mixxx", timeout=10, check=False).strip()),
        "NRave process",
        timeout=timeout,
    )


def prepare_android_runtime() -> None:
    # The clean API-35 emulator can show Android's immersive-mode confirmation
    # and the MANAGE_EXTERNAL_STORAGE special-access screen before the app UI.
    # Those are test-environment state, not NRave UI under test.
    run_shell(
        "settings",
        "put",
        "secure",
        "immersive_mode_confirmations",
        "confirmed",
        timeout=10,
        check=False,
    )
    run_shell(
        "appops",
        "set",
        "org.mixxx",
        "MANAGE_EXTERNAL_STORAGE",
        "allow",
        timeout=10,
        check=False,
    )
    storage_state = run_shell(
        "appops",
        "get",
        "org.mixxx",
        "MANAGE_EXTERNAL_STORAGE",
        timeout=10,
        check=False,
    ).strip()
    print(f"=== STORAGE ACCESS === {storage_state}", flush=True)


def window_dump() -> str:
    return run_shell("dumpsys", "window", "windows", timeout=15, check=False)


def current_focus() -> str:
    output = window_dump()
    for line in output.splitlines():
        if "mCurrentFocus=" in line or "mFocusedApp=" in line:
            return line.strip()
    return output[-1000:]


def splash_present() -> bool:
    return "Splash Screen org.mixxx" in window_dump()


def assert_nrave_foreground() -> None:
    focus = current_focus()
    if "org.mixxx" not in focus:
        raise UiTestError(f"NRave is not the foreground app: {focus}")


def main_ui_visible() -> bool:
    # QML content is not exposed to UIAutomator in this Android runtime. The
    # Android splash can therefore disappear while NRave is still showing its
    # own QML splash. Android Default has a non-empty Library panel in the
    # upper-left; the splash is a uniform background there.
    try:
        from io import BytesIO
        from PIL import Image
    except ImportError:
        return False

    data = subprocess.check_output([ADB, "exec-out", "screencap", "-p"], timeout=30)
    image = Image.open(BytesIO(data)).convert("RGB")
    width, height = image.size
    crop = image.crop((0, 0, min(700, width), min(500, height)))
    background = image.getpixel((0, 0))
    samples = list(crop.getdata())[::8]
    different = sum(
        1 for rgb in samples
        if sum(abs(a - b) for a, b in zip(rgb, background)) > 30
    )
    return different > 1000


def wait_for_main_window(timeout: float = 120.0) -> None:
    def ready() -> bool:
        dismiss_android_system_overlays(timeout=2)
        return (
            "org.mixxx" in current_focus()
            and not splash_present()
            and main_ui_visible()
        )

    wait_until(
        ready,
        "NRave MainWindow content (not Android/Qt splash)",
        timeout=timeout,
        interval=2,
    )
    assert_nrave_foreground()


def safe_find_nodes(value: str, *, exact: bool = False) -> list[ET.Element]:
    try:
        return find_nodes(value, exact=exact)
    except UiTestError:
        # UIAutomator can briefly have no dump while Android is finishing boot.
        return []


def dismiss_android_system_overlays(timeout: float = 15.0) -> None:
    deadline = time.time() + timeout
    anr_waits = 0
    while time.time() < deadline:
        handled = False

        # Android can show a native ANR dialog for Pixel Launcher while the
        # emulator is settling. Never mistake that system dialog for a NRave
        # screen change; choose Wait and re-check the real foreground window.
        anr = safe_find_nodes("isn't responding")
        wait_nodes = safe_find_nodes("Wait", exact=True)
        if anr and wait_nodes:
            click_node(wait_nodes[0])
            anr_waits += 1
            time.sleep(2)
            handled = True
            if anr_waits >= 3:
                raise UiTestError("Android system ANR dialog persisted after three Wait attempts")
            continue

        got_it = safe_find_nodes("Got it", exact=True)
        if got_it:
            click_node(got_it[0])
            time.sleep(1)
            handled = True

        all_files = safe_find_nodes("All files access", exact=True)
        allow_all = safe_find_nodes("Allow access to manage all files", exact=True)
        if all_files or allow_all:
            if allow_all:
                click_node(allow_all[0])
                time.sleep(1)
            run_shell("input", "keyevent", "4", timeout=10, check=False)
            time.sleep(1)
            handled = True

        if not handled:
            return
    # Do not fail here; assert_nrave_foreground() below reports the remaining
    # foreground UI with diagnostics if a system page persists.


def launch() -> None:
    run_shell("am", "force-stop", "org.mixxx", check=False)
    run_shell(
        "monkey",
        "-p",
        "org.mixxx",
        "-c",
        "android.intent.category.LAUNCHER",
        "1",
        timeout=30,
    )
    wait_for_process()
    time.sleep(3)
    # Android 35 may surface the immersive-mode confirmation after the app
    # has already created its window. Clear it immediately before UI interaction.
    for _ in range(3):
        dismiss_android_system_overlays(timeout=5)
        if not safe_find_nodes("Viewing full screen", exact=True):
            break
        time.sleep(1)
    if safe_find_nodes("Viewing full screen", exact=True):
        raise UiTestError("Android immersive-mode confirmation remained on screen after launch")
    wait_for_main_window(timeout=90)
    dismiss_android_system_overlays(timeout=5)
    if safe_find_nodes("Viewing full screen", exact=True):
        raise UiTestError("Android immersive-mode confirmation reappeared after MainWindow became ready")
    time.sleep(2)


def assert_enabled(value: str, expected: bool) -> ET.Element:
    nodes = find_nodes(value, exact=True)
    if not nodes:
        raise UiTestError(f"Cannot find {value!r} to inspect enabled state")
    node = nodes[0]
    enabled = node.attrib.get("enabled", "true").casefold() != "false"
    if enabled != expected:
        raise UiTestError(
            f"Unexpected enabled state for {value!r}: expected {expected}, node={node.attrib}"
        )
    return node


def open_settings_with_cold_start_retry() -> None:
    # A clean API-35 emulator can spend the first launch initializing Mixxx.
    # The Qt QML tree is not exposed to UIAutomator here, so verify the Settings
    # tap by a real screen change and allow one deterministic relaunch.
    for attempt in (1, 2):
        print(f"=== OPEN SETTINGS ATTEMPT {attempt} ===", flush=True)
        baseline = screen_hash()
        click_settings_button()
        try:
            wait_for_screen_change(baseline, timeout=8)
            assert_nrave_foreground()
            screenshot(f"02-settings-attempt-{attempt}.png")
            return
        except UiTestError:
            if attempt == 2:
                raise UiTestError(
                    "Settings did not produce a visible UI change after two launches"
                )
            print("=== COLD START RETRY ===", flush=True)
            run_shell("am", "force-stop", "org.mixxx", check=False)
            time.sleep(2)
            launch()


def main() -> int:
    if not APK.exists():
        raise UiTestError(f"APK not found: {APK}")

    print("=== INSTALL ===", flush=True)
    run_adb("install", "-r", str(APK), timeout=180)
    run_shell("pm", "clear", "org.mixxx", timeout=30)
    run_adb("logcat", "-c", timeout=30)
    prepare_android_runtime()

    print("=== LAUNCH ANDROID DEFAULT ===", flush=True)
    launch()
    screenshot("01-android-default.png")
    log = save_logcat("01-default-logcat.txt")
    assert_no_fatal(log)
    if "Loading resolved QML skin entrypoint" in log and "AndroidDefault" not in log:
        raise UiTestError("Default skin loader did not report AndroidDefault")

    open_settings_with_cold_start_retry()
    screenshot("02-settings.png")

    print("=== OPEN INTERFACE SETTINGS ===", flush=True)
    before_interface = screen_hash()
    click_interface_category()
    wait_for_screen_change(before_interface, timeout=8)
    screenshot("02-interface-settings.png")

    print("=== SELECT LATENIGHT ===", flush=True)
    before_skin = screen_hash()
    select_latenight_skin()
    wait_for_screen_change(before_skin, timeout=8)
    screenshot("03-latenight-selected.png")

    print("=== CLOSE SETTINGS WITHOUT RESTARTING ===", flush=True)
    close_settings()
    time.sleep(2)

    print("=== TEST QUANTIZE ON/OFF ===", flush=True)
    wait_for_value("Deck 1 Quantize OFF", timeout=20)
    click_value("Deck 1 Quantize OFF", exact=True)
    wait_for_value("Deck 1 Quantize ON", timeout=10)
    click_value("Deck 1 Quantize ON", exact=True)
    wait_for_value("Deck 1 Quantize OFF", timeout=10)

    wait_for_value("Deck 2 Quantize OFF", timeout=20)
    click_value("Deck 2 Quantize OFF", exact=True)
    wait_for_value("Deck 2 Quantize ON", timeout=10)
    click_value("Deck 2 Quantize ON", exact=True)
    wait_for_value("Deck 2 Quantize OFF", timeout=10)
    screenshot("04-quantize.png")

    print("=== TEST BITGRID OPEN/CLOSE STATE ===", flush=True)
    click_value("Deck 1 BeatGrid", exact=True)
    wait_for_value("BEATGRID 1", timeout=15, exact=True)
    for label in ("BPM +", "BPM −", "TAP BPM", "EARLIER", "LATER", "ALIGN", "UNDO", "LOCK GRID", "No track loaded"):
        wait_for_value(label, timeout=10, exact=True)

    # No track is loaded in this clean emulator by design. The editor must still
    # expose the controls, but editing actions must be correctly disabled.
    assert_enabled("BPM +", False)
    assert_enabled("BPM −", False)
    assert_enabled("EARLIER", False)
    assert_enabled("LATER", False)
    assert_enabled("ALIGN", False)
    assert_enabled("LOCK GRID", True)

    print("=== TEST BITGRID LOCK CONTROL ===", flush=True)
    click_value("LOCK GRID", exact=True)
    wait_for_value("UNLOCK GRID", timeout=10, exact=True)
    wait_for_value("BeatGrid locked", timeout=10, exact=True)
    click_value("UNLOCK GRID", exact=True)
    wait_for_value("LOCK GRID", timeout=10, exact=True)
    screenshot("05-bitgrid-deck1.png")

    print("=== TEST BITGRID DECK 2 INDEPENDENCE ===", flush=True)
    click_value("Deck 1 BeatGrid", exact=True)
    wait_for_value("BEATGRID 1", timeout=10, exact=True)
    click_value("×", exact=True)
    wait_until(lambda: not find_nodes("BEATGRID 1", exact=True), "Deck 1 panel close", timeout=10)
    click_value("Deck 2 BeatGrid", exact=True)
    wait_for_value("BEATGRID 2", timeout=15, exact=True)
    wait_for_value("LOCK GRID", timeout=10, exact=True)
    click_value("LOCK GRID", exact=True)
    wait_for_value("UNLOCK GRID", timeout=10, exact=True)
    wait_for_value("BeatGrid locked", timeout=10, exact=True)
    click_value("UNLOCK GRID", exact=True)
    wait_for_value("LOCK GRID", timeout=10, exact=True)
    screenshot("06-bitgrid-deck2.png")

    print("=== CLOSE BITGRID ===", flush=True)
    click_value("×", exact=True)
    wait_until(lambda: not find_nodes("BEATGRID 2", exact=True), "BitGrid panel close", timeout=10)

    print("=== SAVE LATENIGHT SELECTION ===", flush=True)
    reopen_settings()
    wait_for_value("Skin: Android Default", timeout=15)
    click_value("Skin: Android Default", exact=True)
    wait_for_value("Late Night QML", timeout=10)
    click_value("Late Night QML", exact=True)
    wait_for_value("Skin: Late Night QML", timeout=10)
    click_value("Save", exact=True)
    time.sleep(2)
    # Save keeps the Settings popup open; this asserts the action completed.
    wait_for_value("Settings", timeout=10, exact=True)
    screenshot("07-settings-saved.png")

    print("=== RESTART AND VERIFY LATENIGHT LOADER ===", flush=True)
    run_shell("am", "force-stop", "org.mixxx")
    run_adb("logcat", "-c", timeout=30)
    launch()
    time.sleep(4)
    log = save_logcat("07-latenight-logcat.txt")
    assert_no_fatal(log)
    if "Loading resolved QML skin entrypoint" not in log or "LateNightQML" not in log:
        raise UiTestError("LateNightQML loader success message not found in logcat")
    if "Failed to load the resolved Mixxx QML skin entrypoint" in log:
        raise UiTestError("LateNightQML loader reported an error")
    wait_for_value("LateNight QML Skin", timeout=30)
    screenshot("08-latenight-loaded.png")

    print("=== TEST LATENIGHT BEATGRID TOGGLE ===", flush=True)
    wait_for_value("Deck 1 BeatGrid Editor ON", timeout=20)
    click_value("Deck 1 BeatGrid Editor ON", exact=True)
    wait_for_value("Deck 1 BeatGrid Editor OFF", timeout=10)
    click_value("Deck 1 BeatGrid Editor OFF", exact=True)
    wait_for_value("Deck 1 BeatGrid Editor ON", timeout=10)
    screenshot("09-latenight-beatgrid.png")

    print("=== FINAL CRASH CHECK ===", flush=True)
    final_log = save_logcat("09-final-logcat.txt")
    assert_no_fatal(final_log)

    print("=== ANDROID UI SMOKE TEST PASSED ===", flush=True)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except UiTestError as exc:
        print(f"TEST FAILURE: {exc}", file=sys.stderr)
        try:
            save_logcat("failure-logcat.txt")
            screenshot("failure-screen.png")
        except Exception as diag_exc:  # noqa: BLE001
            print(f"Diagnostic capture failed: {diag_exc}", file=sys.stderr)
        raise SystemExit(1)
