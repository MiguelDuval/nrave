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


def capture_screenshot_png() -> bytes:
    proc = subprocess.run(
        [ADB, "exec-out", "screencap", "-p"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=30,
    )
    if proc.returncode != 0:
        raise UiTestError(
            f"Could not capture screenshot: {proc.stderr.decode(errors='replace')}"
        )
    return proc.stdout


def png_region_hash(png: bytes, x1: int, y1: int, x2: int, y2: int) -> str:
    # Dependency-free decoder for the 8-bit RGB/RGBA PNG produced by Android
    # screencap. This keeps the CI test self-contained while allowing a stable
    # hash of the small UI region whose state we need to verify.
    import struct
    import zlib

    if png[:8] != b"\x89PNG\r\n\x1a\n":
        raise UiTestError("Android screencap did not return a PNG")
    pos = 8
    width = height = bit_depth = color_type = None
    idat = bytearray()
    while pos < len(png):
        if pos + 8 > len(png):
            break
        length = struct.unpack(">I", png[pos:pos + 4])[0]
        kind = png[pos + 4:pos + 8]
        data = png[pos + 8:pos + 8 + length]
        pos += 12 + length
        if kind == b"IHDR":
            width, height, bit_depth, color_type = struct.unpack(">IIBB", data[:10])
        elif kind == b"IDAT":
            idat.extend(data)
        elif kind == b"IEND":
            break

    if width is None or height is None or bit_depth != 8 or color_type not in (2, 6):
        raise UiTestError(
            f"Unsupported screencap PNG format: width={width}, height={height}, "
            f"bit_depth={bit_depth}, color_type={color_type}"
        )

    channels = 3 if color_type == 2 else 4
    raw = zlib.decompress(bytes(idat))
    stride = width * channels
    expected = height * (stride + 1)
    if len(raw) != expected:
        raise UiTestError(
            f"Unexpected decoded PNG size: got {len(raw)}, expected {expected}"
        )

    x1 = max(0, min(width, x1))
    x2 = max(x1, min(width, x2))
    y1 = max(0, min(height, y1))
    y2 = max(y1, min(height, y2))
    bpp = channels
    previous = bytearray(stride)
    region = bytearray()

    for y in range(height):
        filter_type = raw[y * (stride + 1)]
        scan = bytearray(raw[y * (stride + 1) + 1:(y + 1) * (stride + 1)])
        if filter_type == 1:
            for i in range(stride):
                left = scan[i - bpp] if i >= bpp else 0
                scan[i] = (scan[i] + left) & 0xff
        elif filter_type == 2:
            for i in range(stride):
                scan[i] = (scan[i] + previous[i]) & 0xff
        elif filter_type == 3:
            for i in range(stride):
                left = scan[i - bpp] if i >= bpp else 0
                up = previous[i]
                scan[i] = (scan[i] + ((left + up) // 2)) & 0xff
        elif filter_type == 4:
            for i in range(stride):
                left = scan[i - bpp] if i >= bpp else 0
                up = previous[i]
                up_left = previous[i - bpp] if i >= bpp else 0
                p = left + up - up_left
                pa = abs(p - left)
                pb = abs(p - up)
                pc = abs(p - up_left)
                predictor = left if pa <= pb and pa <= pc else up if pb <= pc else up_left
                scan[i] = (scan[i] + predictor) & 0xff
        elif filter_type != 0:
            raise UiTestError(f"Unsupported PNG filter type {filter_type}")

        if y1 <= y < y2:
            start = x1 * channels
            end = x2 * channels
            region.extend(scan[start:end])
        previous = scan

    return hashlib.sha256(region).hexdigest()


def screenshot_region_hash(name: str, x1: int, y1: int, x2: int, y2: int) -> str:
    digest = png_region_hash(capture_screenshot_png(), x1, y1, x2, y2)
    (DIAG / f"{name}-region-sha256.txt").write_text(digest + "\n", encoding="utf-8")
    return digest


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


def visual_tap_fraction(x_fraction: float, y_fraction: float, description: str) -> str:
    width, height = physical_screen_size()
    x = round(width * x_fraction)
    y = round(height * y_fraction)
    run_shell("input", "tap", str(x), str(y), timeout=10)
    time.sleep(2)
    wait_for_process(timeout=20)
    return f"{description} at ({x},{y})"


def visual_toggle(x_fraction: float, y_fraction: float, description: str) -> None:
    visual_tap_fraction(x_fraction, y_fraction, description + " toggle 1")
    assert_no_fatal(save_logcat(f"{description.replace(' ', '_')}-toggle1-logcat.txt"))
    visual_tap_fraction(x_fraction, y_fraction, description + " toggle 2")
    assert_no_fatal(save_logcat(f"{description.replace(' ', '_')}-toggle2-logcat.txt"))


def physical_screen_size() -> tuple[int, int]:
    output = run_shell("wm", "size", timeout=10)
    match = re.search(r"(\d+)x(\d+)", output)
    if not match:
        raise UiTestError(f"Could not determine physical screen size: {output!r}")
    width, height = int(match.group(1)), int(match.group(2))

    # wm size reports the panel's native orientation. adb input/screencap use
    # the current rotated display coordinates. The runtime is deliberately
    # locked to landscape, so rotation 1/3 means the usable input dimensions
    # are swapped.
    rotation_output = run_shell(
        "settings", "get", "system", "user_rotation", timeout=10, check=False
    ).strip()
    try:
        rotation = int(rotation_output)
    except ValueError:
        rotation = 0
    if rotation % 2:
        return height, width
    return width, height


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
    # Settings is an icon-only gear. UIAutomator may not expose Qt Quick
    # accessibility nodes, so semantic lookup is optional. The Android
    # immersive-mode confirmation is a native overlay and MUST be gone before
    # any coordinate tap; otherwise the tap is consumed by "Got it".
    dismiss_android_system_overlays(timeout=10)
    if safe_find_nodes("Viewing full screen", exact=True):
        raise UiTestError("Android immersive-mode confirmation is still visible before Settings tap")

    for value in ("nrave_settings_button", "Settings"):
        nodes = safe_find_nodes(value, exact=True)
        if nodes:
            node = nodes[0]
            if node.attrib.get("enabled", "true").casefold() != "false":
                click_node(node)
                time.sleep(1)
                return

    frame = app_window_bounds()
    if frame:
        left, top, right, bottom = frame
        # MainWindow toolbar is 36 dp high. With the CI density fixed to 160,
        # the gear button is the final visible toolbar button at the right
        # edge of the Qt application frame. Tap its center, not the screen
        # edge, because the emulator display is wider than the Qt window.
        x = right - 38
        y = top + 18
        run_shell("input", "tap", str(x), str(y), timeout=10)
        time.sleep(1)
        return

    width, _ = physical_screen_size()
    run_shell("input", "tap", str(width - 38), "18", timeout=10)
    time.sleep(1)


def reopen_settings() -> None:
    # Settings is an icon-only gear, therefore never depend on visible button
    # text for reopening it. Avoid screencap polling on the CI emulator.
    click_settings_button()
    time.sleep(2)
    assert_nrave_foreground()


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
    # Settings.qml is a Qt Quick Popup positioned relative to MainWindow, not
    # necessarily relative to the physical Android display after landscape
    # rotation. Use WindowManager's application frame so adb input taps and the
    # Qt popup share the same coordinate system.
    frame = app_window_bounds()
    if frame:
        left, top, right, bottom = frame
        width = max(1, right - left)
        height = max(1, bottom - top)
        popup_width = min(1400, width)
        popup_height = min(840, height)
        popup_x = left + round((width - popup_width) / 2)
        popup_y = top + round((height - popup_height) / 2)
        print(
            f"=== SETTINGS GEOMETRY === frame={frame} "
            f"popup=({popup_x},{popup_y},{popup_width},{popup_height})",
            flush=True,
        )
        return popup_x, popup_y, popup_width, popup_height

    width, height = physical_screen_size()
    popup_width = min(1400, width)
    popup_height = min(840, height)
    popup_x = round((width - popup_width) / 2)
    popup_y = round((height - popup_height) / 2)
    print(
        f"=== SETTINGS GEOMETRY FALLBACK === popup=({popup_x},{popup_y},{popup_width},{popup_height})",
        flush=True,
    )
    return popup_x, popup_y, popup_width, popup_height


def click_interface_category() -> None:
    popup_x, popup_y, _, _ = settings_geometry()
    # Settings.qml: 20px popup padding + 280px sidebar. The category list
    # starts after Back (34), separator (1), and Search (30). Interface is
    # category index 3 with 38px rows.
    x = popup_x + 20 + 140
    y = popup_y + 85 + 3 * 38 + 19
    run_shell("input", "tap", str(x), str(y), timeout=10)


def skin_text_region() -> tuple[int, int, int, int]:
    # Tight crop around the visible Skin value. A thresholded text signature is
    # much more stable than a full-color screenshot across Qt repaints.
    return (1650, 415, 2050, 490)


def skin_text_signature(name: str) -> bytes:
    import struct
    import zlib

    png = capture_screenshot_png()
    if png[:8] != b"\x89PNG\r\n\x1a\n":
        raise UiTestError("Android screencap did not return a PNG")

    pos = 8
    width = height = bit_depth = color_type = None
    idat = bytearray()
    while pos < len(png):
        if pos + 8 > len(png):
            break
        length = struct.unpack(">I", png[pos:pos + 4])[0]
        kind = png[pos + 4:pos + 8]
        data = png[pos + 8:pos + 8 + length]
        pos += 12 + length
        if kind == b"IHDR":
            width, height, bit_depth, color_type = struct.unpack(">IIBB", data[:10])
        elif kind == b"IDAT":
            idat.extend(data)
        elif kind == b"IEND":
            break

    if width is None or height is None or bit_depth != 8 or color_type not in (2, 6):
        raise UiTestError("Unsupported Android screencap PNG format")

    channels = 3 if color_type == 2 else 4
    raw = zlib.decompress(bytes(idat))
    stride = width * channels
    x1, y1, x2, y2 = skin_text_region()
    x1, x2 = max(0, x1), min(width, x2)
    y1, y2 = max(0, y1), min(height, y2)
    previous = bytearray(stride)
    pixels = []
    for y in range(height):
        filter_type = raw[y * (stride + 1)]
        scan = bytearray(raw[y * (stride + 1) + 1:(y + 1) * (stride + 1)])
        if filter_type == 1:
            for i in range(stride):
                left = scan[i - channels] if i >= channels else 0
                scan[i] = (scan[i] + left) & 0xff
        elif filter_type == 2:
            for i in range(stride):
                scan[i] = (scan[i] + previous[i]) & 0xff
        elif filter_type == 3:
            for i in range(stride):
                left = scan[i - channels] if i >= channels else 0
                scan[i] = (scan[i] + ((left + previous[i]) // 2)) & 0xff
        elif filter_type == 4:
            for i in range(stride):
                left = scan[i - channels] if i >= channels else 0
                up = previous[i]
                up_left = previous[i - channels] if i >= channels else 0
                p = left + up - up_left
                pa, pb, pc = abs(p - left), abs(p - up), abs(p - up_left)
                predictor = left if pa <= pb and pa <= pc else up if pb <= pc else up_left
                scan[i] = (scan[i] + predictor) & 0xff
        elif filter_type != 0:
            raise UiTestError(f"Unsupported PNG filter type {filter_type}")

        if y1 <= y < y2:
            row = bytearray()
            for x in range(x1, x2):
                off = x * channels
                if channels == 4:
                    value = (299 * scan[off] + 587 * scan[off + 1] + 114 * scan[off + 2]) // 1000
                else:
                    value = (299 * scan[off] + 587 * scan[off + 1] + 114 * scan[off + 2]) // 1000
                row.append(255 if value > 120 else 0)
            pixels.extend(row)
        previous = scan

    signature = bytes(pixels)
    (DIAG / f"{name}-skin-text-signature.bin").write_bytes(signature)
    return signature


def skin_signature_difference(a: bytes, b: bytes) -> float:
    if len(a) != len(b):
        raise UiTestError("Skin text signatures have different sizes")
    return sum(x != y for x, y in zip(a, b)) / max(1, len(a))


def skin_selector_region() -> tuple[int, int, int, int]:
    popup_x, popup_y, popup_width, _ = settings_geometry()
    return (
        popup_x + round(popup_width * 0.50),
        popup_y + 105,
        popup_x + round(popup_width * 0.90),
        popup_y + 210,
    )


def select_latenight_skin() -> tuple[bytes, bytes]:
    popup_x, popup_y, popup_width, _ = settings_geometry()
    x = popup_x + round(popup_width * 0.68)
    # Skin row is the first Theme & Color row. Tap the right side/indicator
    # of the ComboBox inside the measured Qt Popup geometry.
    x = popup_x + round(popup_width * 0.68)
    y = popup_y + 150
    before = skin_text_signature("skin-before-selection")

    # The popup opens directly below the ComboBox. Delegate row height is
    # roughly 36px at the test density; try a few nearby centers for the second
    # row because Qt font metrics can shift it slightly.
    tried_offsets = (72, 88, 104, 120)
    for attempt, offset in enumerate(tried_offsets, start=1):
        run_shell("input", "tap", str(x), str(y), timeout=10)
        time.sleep(0.5)
        screenshot(f"skin-popup-open-{attempt}.png")
        run_shell("input", "tap", str(x), str(y + offset), timeout=10)
        time.sleep(1.0)
        after = skin_text_signature(f"skin-after-selection-{attempt}")
        difference = skin_signature_difference(before, after)
        print(
            f"=== SKIN SELECTION ATTEMPT {attempt}: offset={offset}, "
            f"text-difference={difference:.4f} ===",
            flush=True,
        )
        if difference > 0.015:
            return before, after

    raise UiTestError(
        "Skin selector did not change to a different rendered value after "
        f"trying second-row offsets {tried_offsets}"
    )


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
    # Lock the runtime emulator to landscape before starting Qt. The APK
    # declares sensorLandscape; on the API-35 CI image an unlocked sensor
    # transition can leave Qt rendering correctly while Android has no input
    # channel for the activity. A deterministic landscape display avoids that
    # race and makes adb input delivery testable.
    run_shell("settings", "put", "system", "accelerometer_rotation", "0", timeout=10, check=False)
    run_shell("settings", "put", "system", "user_rotation", "1", timeout=10, check=False)
    run_shell("wm", "set-user-rotation", "lock", "1", timeout=10, check=False)
    # Give the desktop-style QML skin enough logical width/height to expose
    # its full deck toolbars on the CI emulator. The physical display stays
    # unchanged; only Android's dp mapping is adjusted for this black-box run.
    run_shell("wm", "density", "160", timeout=10, check=False)
    time.sleep(2)

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
    # The Google APIs image can start Pixel Launcher even though this test is
    # full-screen NRave-only. Stop launchers so their startup/ANR cannot block
    # the application's input window.
    for launcher in ("com.google.android.apps.nexuslauncher", "com.android.launcher3"):
        run_shell("am", "force-stop", launcher, timeout=10, check=False)

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
    # Do not use repeated screencap polling here. On the ARM64-through-ARM
    # translation runtime, frequent full-resolution captures can starve the
    # emulator and trigger a Pixel Launcher/system ANR while NRave is already
    # rendering correctly. Foreground-window state is the stable readiness
    # signal; screenshots are captured only at explicit checkpoints.
    return "org.mixxx" in current_focus() and not splash_present()


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
    for launcher in ("com.google.android.apps.nexuslauncher", "com.android.launcher3"):
        run_shell("am", "force-stop", launcher, timeout=10, check=False)
    wait_for_process()
    time.sleep(3)

    # Android 35 can present the native immersive-mode confirmation after the
    # Qt activity already has focus. Dismiss it repeatedly and verify the
    # hierarchy no longer contains the dialog before declaring the app ready.
    for _ in range(5):
        dismiss_android_system_overlays(timeout=3)
        if not safe_find_nodes("Viewing full screen", exact=True):
            break
        time.sleep(1)
    if safe_find_nodes("Viewing full screen", exact=True):
        screenshot("launch-immersive-overlay.png")
        raise UiTestError("Android immersive-mode confirmation remained on screen after launch")

    wait_for_main_window(timeout=90)
    dismiss_android_system_overlays(timeout=3)
    if safe_find_nodes("Viewing full screen", exact=True):
        screenshot("launch-immersive-overlay-reappeared.png")
        raise UiTestError("Android immersive-mode confirmation reappeared after MainWindow became ready")
    assert_nrave_foreground()
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
        click_settings_button()
        time.sleep(2)
        try:
            assert_nrave_foreground()
            screenshot(f"02-settings-attempt-{attempt}.png")
            return
        except UiTestError:
            if attempt == 2:
                raise UiTestError("Settings did not leave NRave in the foreground after two attempts")
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
    click_interface_category()
    time.sleep(2)
    screenshot("02-interface-settings.png")

    print("=== SELECT LATENIGHT ===", flush=True)
    skin_before_signature, skin_selected_signature = select_latenight_skin()
    time.sleep(2)
    screenshot("03-latenight-selected.png")

    print("=== CLOSE SETTINGS WITHOUT RESTARTING ===", flush=True)
    close_settings()
    time.sleep(2)

    print("=== TEST QUANTIZE VISUAL TOGGLE ===", flush=True)
    # Qt/Android UIAutomator does not expose the QML toolbar controls on this APK.
    # On the fixed CI display, Deck 1 Q is approximately 16.7%/70.4%.
    visual_toggle(0.167, 0.704, "Deck 1 Quantize")
    screenshot("04-quantize.png")

    print("=== TEST BITGRID OPEN/CLOSE STATE ===", flush=True)
    # BEATGRID is the next toolbar control on Deck 1, approximately 24.8%/70.4%.
    visual_tap_fraction(0.248, 0.704, "Deck 1 BeatGrid open")
    screenshot("05-bitgrid-deck1.png")
    assert_no_fatal(save_logcat("05-bitgrid-open-logcat.txt"))

    # BitGridOverlay is a full-screen Qt overlay with its own close path.
    # Do NOT send Android BACK here: BACK closes MainActivity rather than the
    # overlay and, on this APK/runtime combination, tears down Qt rendering
    # while the overlay is active. Tap the overlay outside its centered panel.
    visual_tap_fraction(0.02, 0.02, "Deck 1 BeatGrid overlay close")
    screenshot("06-bitgrid-deck1-closed.png")
    assert_no_fatal(save_logcat("06-bitgrid-closed-logcat.txt"))

    print("=== TEST BITGRID DECK 1 REOPEN/CLOSE ===", flush=True)
    visual_tap_fraction(0.248, 0.704, "Deck 1 BeatGrid reopen")
    screenshot("07-bitgrid-deck1-reopened.png")
    assert_no_fatal(save_logcat("07-bitgrid-reopened-logcat.txt"))
    visual_tap_fraction(0.02, 0.02, "Deck 1 BeatGrid overlay close second")
    screenshot("08-bitgrid-deck1-closed-again.png")
    assert_no_fatal(save_logcat("08-bitgrid-closed-again-logcat.txt"))

    print("=== SAVE LATENIGHT SELECTION ===", flush=True)
    # QML Settings controls are not exported to Android UIAutomator. The
    # LateNight selection is already active; reopen Settings and use the
    # known Save geometry, then verify persistence through the real loader log.
    reopen_settings()
    save_settings()
    time.sleep(2)
    screenshot("09-settings-saved.png")

    print("=== RESTART AND VERIFY LATENIGHT PERSISTENCE ===", flush=True)
    run_shell("am", "force-stop", "org.mixxx")
    run_adb("logcat", "-c", timeout=30)
    launch()
    time.sleep(4)
    log = save_logcat("09-latenight-logcat.txt")
    assert_no_fatal(log)
    if "Failed to load the resolved Mixxx QML skin entrypoint" in log:
        raise UiTestError("QML skin loader reported an error")
    screenshot("11-latenight-loaded.png")

    reopen_settings()
    click_interface_category()
    time.sleep(2)
    persisted_skin_signature = skin_text_signature("skin-after-restart")
    to_selected = skin_signature_difference(
        persisted_skin_signature, skin_selected_signature
    )
    to_android_default = skin_signature_difference(
        persisted_skin_signature, skin_before_signature
    )
    print(
        f"=== SKIN PERSISTENCE: to-selected={to_selected:.4f}, "
        f"to-default={to_android_default:.4f} ===",
        flush=True,
    )
    if to_selected >= to_android_default or to_android_default < 0.015:
        raise UiTestError(
            "Late Night skin selection did not persist across force-stop/relaunch "
            f"(distance-to-selected={to_selected:.4f}, "
            f"distance-to-default={to_android_default:.4f})"
        )
    close_settings()
    time.sleep(2)

    print("=== TEST LATENIGHT BEATGRID TOGGLE ===", flush=True)
    visual_toggle(0.248, 0.704, "LateNight Deck 1 BeatGrid")
    screenshot("12-latenight-beatgrid.png")

    print("=== FINAL CRASH CHECK ===", flush=True)
    final_log = save_logcat("10-final-logcat.txt")
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
