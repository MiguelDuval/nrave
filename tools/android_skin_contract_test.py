#!/usr/bin/env python3
"""Minimal Android skin contract test for Nrave Stage 4.

This intentionally does not test LateNight internals. It proves only that:
1. SkinLoader resolves the configured skin.
2. QmlApplication passes that resolved skin into the single shell.
3. main.qml loads that skin's MainWindow.qml.
4. The loaded skin receives the shell ApplicationWindow.
5. The selection survives a restart.

The test uses the same emulator setup strategy as the Stage 3 harness, but
avoids pixel signatures, screen hashes, and feature-specific UI assertions.
"""

from __future__ import annotations

import os
import re
import subprocess
import sys
import time
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
APK = Path(os.environ.get(
    "NRAVE_APK",
    ROOT / "runtime-apk" / "android-build-release-signed.apk",
))
PACKAGE = "org.mixxx"
DIAG = ROOT / os.environ.get("NRAVE_DIAG_DIR", "nrave-ui-test-diagnostics")
DIAG.mkdir(parents=True, exist_ok=True)


class TestFailure(RuntimeError):
    pass


def run(*args: str, timeout: int = 60, check: bool = True) -> str:
    proc = subprocess.run(
        list(args),
        text=True,
        capture_output=True,
        timeout=timeout,
    )
    if check and proc.returncode != 0:
        raise TestFailure(
            f"Command failed ({proc.returncode}): {' '.join(args)}\n"
            f"stdout:\n{proc.stdout}\nstderr:\n{proc.stderr}"
        )
    return proc.stdout


def adb(*args: str, timeout: int = 60, check: bool = True) -> str:
    return run("adb", *args, timeout=timeout, check=check)


def shell(*args: str, timeout: int = 60, check: bool = True) -> str:
    return adb("shell", *args, timeout=timeout, check=check)


def sleep(seconds: float) -> None:
    time.sleep(seconds)


def save_logcat(name: str) -> str:
    pids = shell("pidof", PACKAGE, timeout=10, check=False).strip().split()
    if pids:
        data = adb("logcat", "--pid", pids[0], "-d", timeout=30)
    else:
        data = adb("logcat", "-d", timeout=30)
    (DIAG / name).write_text(data, encoding="utf-8")
    return data


def app_logcat() -> str:
    pids = shell("pidof", PACKAGE, timeout=10, check=False).strip().split()
    if not pids:
        return ""
    return adb("logcat", "--pid", pids[0], "-d", timeout=30)


def wait_for_log(needles: tuple[str, ...], description: str, timeout: int = 120) -> str:
    deadline = time.time() + timeout
    last = ""
    while time.time() < deadline:
        last = app_logcat()
        if all(needle in last for needle in needles):
            return last
        time.sleep(2)
    recent = "\n".join(last.splitlines()[-80:])
    raise TestFailure(
        f"Timed out waiting for {description}.\n"
        f"Required markers: {needles}\nRecent app log:\n{recent}"
    )


def prepare_runtime() -> None:
    shell(
        "settings", "put", "system", "accelerometer_rotation", "0",
        timeout=10, check=False,
    )
    shell(
        "settings", "put", "system", "user_rotation", "1",
        timeout=10, check=False,
    )
    shell(
        "wm", "set-user-rotation", "lock", "1",
        timeout=10, check=False,
    )
    shell("wm", "density", "160", timeout=10, check=False)
    shell(
        "settings", "put", "secure", "immersive_mode_confirmations", "confirmed",
        timeout=10, check=False,
    )
    shell(
        "appops", "set", PACKAGE, "MANAGE_EXTERNAL_STORAGE", "allow",
        timeout=10, check=False,
    )
    for launcher in ("com.google.android.apps.nexuslauncher", "com.android.launcher3"):
        shell("am", "force-stop", launcher, timeout=10, check=False)
    sleep(2)


def launch() -> None:
    shell("am", "force-stop", PACKAGE, timeout=15, check=False)
    shell(
        "monkey",
        "-p", PACKAGE,
        "-c", "android.intent.category.LAUNCHER",
        "1",
        timeout=30,
    )
    sleep(4)


def app_frame() -> tuple[int, int, int, int]:
    out = shell("dumpsys", "window", "windows", timeout=15, check=False)
    candidates: list[tuple[int, int, int, int]] = []
    for line in out.splitlines():
        if PACKAGE not in line:
            continue
        m = re.search(r"mFrame=Rect\((-?\d+),(-?\d+) - (-?\d+),(-?\d+)\)", line)
        if not m:
            continue
        frame = tuple(map(int, m.groups()))
        width = max(0, frame[2] - frame[0])
        height = max(0, frame[3] - frame[1])
        if width > 500 and height > 300:
            candidates.append(frame)
    if not candidates:
        raise TestFailure("Could not find the NRave application frame")
    return max(candidates, key=lambda f: (f[2] - f[0]) * (f[3] - f[1]))


def tap(x: int, y: int) -> None:
    shell("input", "tap", str(x), str(y), timeout=10)
    sleep(1)


def open_settings() -> tuple[int, int, int, int]:
    left, top, right, bottom = app_frame()
    tap(right - 38, top + 18)
    sleep(2)
    return settings_geometry()


def settings_geometry() -> tuple[int, int, int, int]:
    left, top, right, bottom = app_frame()
    width = max(1, right - left)
    height = max(1, bottom - top)
    popup_width = min(1400, width)
    popup_height = min(840, height)
    popup_x = left + round((width - popup_width) / 2)
    popup_y = top + round((height - popup_height) / 2)
    return popup_x, popup_y, popup_width, popup_height


def open_interface_category(popup: tuple[int, int, int, int]) -> None:
    popup_x, popup_y, _, _ = popup
    # Matches the stable category layout used by the existing QML Settings page.
    tap(
        popup_x + 160,
        popup_y + 85 + 3 * 38 + 19,
    )


def skin_selector_point(popup: tuple[int, int, int, int]) -> tuple[int, int]:
    popup_x, popup_y, popup_width, _ = popup
    return (
        popup_x + round(popup_width * 0.684),
        popup_y + 169,
    )


def choose_skin(index: int, popup: tuple[int, int, int, int]) -> None:
    x, y = skin_selector_point(popup)
    tap(x, y)
    # ComboBox delegate rows are about 36 px at the deterministic CI density.
    row_offsets = (18, 72) if index == 0 else (72, 88, 104, 120)
    for offset in row_offsets:
        tap(x, y + offset)
        sleep(1)
        # The selected value is persisted by the QML Config proxy. We cannot
        # query the QML object tree through UIAutomator, so the restart below
        # is the authoritative assertion.
        if index == 0:
            return
        # A second-row selection can be retried at a few nearby row centers.
        # Re-open the selector on each attempt after the first.
        if offset != row_offsets[-1]:
            tap(x, y)
    raise TestFailure("Could not select Test Skin from the Android selector")


def save_settings() -> None:
    popup_x, popup_y, popup_width, popup_height = settings_geometry()
    tap(
        popup_x + popup_width - 45,
        popup_y + popup_height - 10,
    )
    sleep(2)


def select_and_save_skin(index: int, description: str) -> None:
    popup = open_settings()
    open_interface_category(popup)
    sleep(1)
    choose_skin(index, popup)
    save_settings()
    save_logcat(f"{description}-settings-logcat.txt")


def assert_skin_ready(expected: str, log: str) -> None:
    required = (
        f'NRAVE_SKIN_RESOLVED skin= "{expected}"',
        f'NRAVE_QML_SHELL_RESOLVED skin= "{expected}"',
        f"NRAVE_QML_SHELL_LOADING_SKIN {expected}",
        f"NRAVE_QML_SHELL_SKIN_READY {expected}",
    )
    missing = [marker for marker in required if marker not in log]
    if missing:
        raise TestFailure(
            f"{expected} did not complete the shell contract. Missing: {missing}\n"
            f"Recent log:\n" + "\n".join(log.splitlines()[-100:])
        )


def main() -> int:
    if not APK.exists():
        raise TestFailure(f"APK not found: {APK}")

    prepare_runtime()

    print("=== INSTALL ===", flush=True)
    adb("install", "-r", str(APK), timeout=180)
    shell("pm", "clear", PACKAGE, timeout=30)
    adb("logcat", "-c", timeout=30)

    print("=== ANDROID DEFAULT BOOT ===", flush=True)
    launch()
    log = wait_for_log(
        (
            'NRAVE_SKIN_RESOLVED skin= "AndroidDefault"',
            "NRAVE_QML_SHELL_SKIN_READY AndroidDefault",
        ),
        "Android Default shell contract",
    )
    save_logcat("01-android-default.txt")
    assert_skin_ready("AndroidDefault", log)

    print("=== SELECT TEST SKIN ===", flush=True)
    select_and_save_skin(1, "02-test-skin-selection")

    print("=== TEST SKIN RESTART ===", flush=True)
    adb("logcat", "-c", timeout=30)
    launch()
    log = wait_for_log(
        (
            'NRAVE_SKIN_RESOLVED skin= "TestSkin"',
            "NRAVE_QML_SHELL_SKIN_READY TestSkin",
            "NRAVE_SKIN_CONTRACT_TEST ready",
        ),
        "Test Skin shell contract",
    )
    save_logcat("03-test-skin-ready.txt")
    assert_skin_ready("TestSkin", log)

    print("=== RETURN TO ANDROID DEFAULT ===", flush=True)
    select_and_save_skin(0, "04-default-selection")

    print("=== ANDROID DEFAULT RESTART ===", flush=True)
    adb("logcat", "-c", timeout=30)
    launch()
    log = wait_for_log(
        (
            'NRAVE_SKIN_RESOLVED skin= "AndroidDefault"',
            "NRAVE_QML_SHELL_SKIN_READY AndroidDefault",
        ),
        "Android Default return contract",
    )
    save_logcat("05-android-default-return.txt")
    assert_skin_ready("AndroidDefault", log)

    print("=== STAGE 4 SKIN CONTRACT PASSED ===", flush=True)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except TestFailure as exc:
        print(f"TEST FAILURE: {exc}", file=sys.stderr)
        try:
            save_logcat("failure-logcat.txt")
        except Exception as diag_exc:
            print(f"Could not capture failure log: {diag_exc}", file=sys.stderr)
        raise SystemExit(1)
