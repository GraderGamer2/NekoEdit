#!/usr/bin/env python3
"""Capability-aware live probe for NekoEdit's optional text-input-v3 client.

The Python process is the direct parent of NekoEdit so Linux's normal
parent-to-child /proc access rules permit inspection of the child's symbol
state without ptrace attach or a debugger. This is test-only instrumentation;
it does not add a diagnostic interface or dependency to the editor.
"""
from __future__ import annotations

import os
import re
import signal
import subprocess
import sys
import time
from pathlib import Path

BUS_NAME = "org.nekoedit.TestHarness"
OBJECT_PATH = "/org/nekoedit/TestHarness"
DBUS_INTERFACE = "org.nekoedit.TestHarness"

SYMBOLS = (
    "text_input_manager_global",
    "text_input_manager_object",
    "text_input_object",
    "text_input_entered",
    "text_input_enabled",
    "text_input_commit_serial",
    "text_input_state_ready",
)


def fail(message: str) -> None:
    raise RuntimeError(message)


def run_nm(binary: str) -> dict[str, int]:
    result = subprocess.run(
        ["nm", "-n", "--defined-only", binary],
        check=True,
        capture_output=True,
        text=True,
    )
    addresses: dict[str, int] = {}
    for line in result.stdout.splitlines():
        match = re.match(r"^([0-9a-fA-F]+)\s+\w\s+(.+)$", line)
        if match:
            name = match.group(2).strip()
            if name in SYMBOLS:
                addresses[name] = int(match.group(1), 16)
    missing = [name for name in SYMBOLS if name not in addresses]
    if missing:
        fail("unavailable NekoEdit probe symbols from nm: " + ", ".join(missing))
    return addresses


def call_gdbus(method: str, *arguments: object) -> str:
    command = [
        "gdbus", "call", "--session",
        "--dest", BUS_NAME,
        "--object-path", OBJECT_PATH,
        "--method", f"{DBUS_INTERFACE}.{method}",
        *(str(argument) for argument in arguments),
    ]
    result = subprocess.run(
        command, check=True, capture_output=True, text=True, timeout=8
    )
    return result.stdout.strip()


def read_state(memory_fd: int, addresses: dict[str, int]) -> dict[str, int]:
    values: dict[str, int] = {}
    for name, address in addresses.items():
        raw = os.pread(memory_fd, 4, address)
        if len(raw) != 4:
            fail(f"could not read 4-byte probe symbol {name}")
        values[name] = int.from_bytes(raw, "little", signed=False)
    return values


def send_key(keysym: int, pressed: bool) -> None:
    call_gdbus("SendKey", keysym, "true" if pressed else "false")


def send_keysym(keysym: int) -> None:
    send_key(keysym, True)
    time.sleep(0.05)
    send_key(keysym, False)
    time.sleep(0.05)


def send_shortcut(modifier: int, keysym: int) -> None:
    send_key(modifier, True)
    time.sleep(0.05)
    send_key(keysym, True)
    time.sleep(0.05)
    send_key(keysym, False)
    time.sleep(0.05)
    send_key(modifier, False)
    time.sleep(0.05)


def wait_input_idle() -> None:
    deadline = time.monotonic() + 5.0
    last = ""
    while time.monotonic() < deadline:
        last = call_gdbus("InputStatus")
        if "ready:pending=0" in last:
            return
        if "failed:" in last:
            fail("Mutter virtual input failed: " + last)
        time.sleep(0.05)
    fail("Mutter virtual input queue did not drain: " + last)


def read_log(path: Path) -> str:
    try:
        return path.read_text(errors="replace")[-6000:]
    except OSError:
        return "(NekoEdit log unavailable)"


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: mutter_text_input_probe.py PATH/TO/nekoedit "
            "PATH/TO/document.txt PATH/TO/nekoedit.log",
            file=sys.stderr,
        )
        return 2

    binary = str(Path(sys.argv[1]).resolve())
    document = Path(sys.argv[2])
    log_path = Path(sys.argv[3])
    addresses = run_nm(binary)

    environment = os.environ.copy()
    environment["NEKOEDIT_ENABLE_TEXT_INPUT"] = "1"
    environment["NEKOEDIT_LOCALE"] = "pt_BR.UTF-8"

    process: subprocess.Popen[bytes] | None = None
    memory_fd: int | None = None
    log_file = None
    try:
        document.write_bytes(b"seed")
        log_file = log_path.open("wb")
        process = subprocess.Popen(
            [binary, str(document)],
            stdin=subprocess.DEVNULL,
            stdout=log_file,
            stderr=subprocess.STDOUT,
            env=environment,
        )

        if process.poll() is not None:
            fail(f"NekoEdit exited during startup with status {process.returncode}")

        memory_fd = os.open(f"/proc/{process.pid}/mem", os.O_RDONLY)

        # Activate the actual NekoEdit MetaWindow rather than assuming that
        # successful process launch implies keyboard focus.
        focus = ""
        deadline = time.monotonic() + 10.0
        while time.monotonic() < deadline and process.poll() is None:
            focus = call_gdbus("Activate", process.pid)
            if f"target={process.pid} focus={process.pid}" in focus:
                break
            time.sleep(0.1)
        else:
            fail("Mutter did not focus the text-input probe window: " + focus)

        call_gdbus("ClickEditor", process.pid)
        pointer = ""
        deadline = time.monotonic() + 5.0
        while time.monotonic() < deadline and process.poll() is None:
            pointer = call_gdbus("PointerStatus")
            if "clicked:" in pointer:
                break
            if "failed:" in pointer:
                fail("Mutter document click failed: " + pointer)
            time.sleep(0.05)
        else:
            fail("Mutter document click did not complete: " + pointer)

        # Let registry dispatch and the text-input focus transition settle
        # before deciding whether the compositor advertises protocol v3.
        state: dict[str, int] = {}
        deadline = time.monotonic() + 4.0
        while time.monotonic() < deadline and process.poll() is None:
            state = read_state(memory_fd, addresses)
            if state["text_input_manager_global"]:
                break
            time.sleep(0.1)

        if process.poll() is not None:
            fail(f"NekoEdit exited during focus probe with status {process.returncode}")

        if state["text_input_manager_global"]:
            # A provider need not generate preedit for this client-side
            # manager-bind, focus-enter, enable, and state-commit handshake.
            deadline = time.monotonic() + 6.0
            while time.monotonic() < deadline and process.poll() is None:
                state = read_state(memory_fd, addresses)
                if (
                    state["text_input_manager_object"]
                    and state["text_input_object"]
                    and state["text_input_entered"] == 1
                    and state["text_input_enabled"] == 1
                    and state["text_input_commit_serial"] >= 1
                    and state["text_input_state_ready"] == 1
                ):
                    print(
                        "PASS: compositor advertised text-input-v3; NekoEdit "
                        "bound the manager, received text-input enter, enabled "
                        "the focused document, and committed state."
                    )
                    return 0
                time.sleep(0.1)
            fail(
                "compositor advertised text-input-v3 but the focused-document "
                f"handshake did not complete; observed state={state}"
            )

        # On compositors without the protocol global, opting in must not
        # create a text-input object or suppress the normal XKB keyboard path.
        unexpected = {
            name: value for name, value in state.items()
            if name != "text_input_manager_global" and value != 0
        }
        if unexpected:
            fail(
                "text-input-v3 manager was not advertised but client state "
                f"was partially initialized: {unexpected}"
            )

        send_shortcut(65507, 97)  # Ctrl+A
        send_keysym(122)          # z
        send_shortcut(65507, 115) # Ctrl+S
        send_keysym(65293)        # Enter confirms the default save prompt
        wait_input_idle()

        deadline = time.monotonic() + 5.0
        while time.monotonic() < deadline and process.poll() is None:
            if document.read_bytes() == b"z":
                print(
                    "PASS: compositor omitted text-input-v3; explicit opt-in "
                    "left the protocol client inactive and ordinary Wayland/"
                    "XKB typing plus confirmed save still worked."
                )
                return 0
            time.sleep(0.1)
        fail(
            "text-input-v3 fallback branch did not preserve physical XKB "
            "typing/save; document bytes=" + repr(document.read_bytes())
        )
    except Exception as error:
        print(f"text-input-v3 Mutter probe failed: {error}", file=sys.stderr)
        print(read_log(log_path), file=sys.stderr)
        return 1
    finally:
        if memory_fd is not None:
            os.close(memory_fd)
        if process is not None and process.poll() is None:
            process.send_signal(signal.SIGTERM)
            try:
                process.wait(timeout=2.0)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
        if log_file is not None:
            log_file.close()


if __name__ == "__main__":
    raise SystemExit(main())
