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


def click_settings_button() -> None:
    # QML's icon-only Settings button is not exposed as a UIAutomator node on
    # the Android runtime used by this test. The button is the fixed 76x36
    # logical-pixel control at the far right of MainWindow's top toolbar.
    width, height = physical_screen_size()
    x = round(width * 0.907)
    y = max(40, round(height * 0.047))
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


def dismiss_android_system_overlays(timeout: float = 15.0) -> None:
    deadline = time.time() + timeout
    while time.time() < deadline:
        handled = False

        got_it = find_nodes("Got it", exact=True)
        if got_it:
            click_node(got_it[0])
            time.sleep(1)
            handled = True

        all_files = find_nodes("All files access", exact=True)
        allow_all = find_nodes("Allow access to manage all files", exact=True)
        if all_files or allow_all:
            if allow_all:
                click_node(allow_all[0])
                time.sleep(1)
            run_shell("input", "keyevent", "4", timeout=10, check=False)
            time.sleep(1)
            handled = True

        if not handled:
            return
    # Do not fail here; the normal app assertions below will report the
    # remaining foreground UI with diagnostics if a system page persists.


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
    dismiss_android_system_overlays()
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

    print("=== OPEN SETTINGS ===", flush=True)
    settings_nodes = find_nodes("Settings", exact=True)
    if settings_nodes:
        click_node(settings_nodes[0])
    else:
        click_settings_button()
    wait_for_any_value(("Settings", "← Back to NRave"), timeout=20)
    screenshot("02-settings.png")

    print("=== OPEN INTERFACE SETTINGS ===", flush=True)
    click_value("Interface", exact=True)
    wait_for_value("Skin: Android Default", timeout=20)
    screenshot("02-interface-settings.png")

    print("=== SELECT LATENIGHT ===", flush=True)
    click_value("Skin: Android Default", exact=True)
    wait_for_value("Late Night QML", timeout=10)
    click_value("Late Night QML", exact=True)
    wait_for_value("Skin: Late Night QML", timeout=10)
    screenshot("03-latenight-selected.png")

    print("=== CLOSE SETTINGS WITHOUT RESTARTING ===", flush=True)
    click_value("Back to NRave", exact=True)
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
    click_value("Settings", exact=True)
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
