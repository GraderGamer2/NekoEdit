#!/usr/bin/env python3
"""Live Mutter/IBus probe for NekoEdit's optional text-input-v3 client.

The Python process is the direct parent of NekoEdit so Linux's normal
parent-to-child /proc access rules permit inspection of the child's protocol
and preedit state without ptrace attach or a debugger. This is test-only
instrumentation; it does not add a diagnostic interface or dependency to the
editor.
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
    "text_input_preedit_length",
    "doc_length",
)

BUFFER_SYMBOLS = ("text_input_preedit_buffer",)


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
            if name in (*SYMBOLS, *BUFFER_SYMBOLS):
                addresses[name] = int(match.group(1), 16)
    missing = [name for name in (*SYMBOLS, *BUFFER_SYMBOLS) if name not in addresses]
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
        if name in BUFFER_SYMBOLS:
            continue
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


def read_preedit(
    memory_fd: int, addresses: dict[str, int], state: dict[str, int]
) -> str:
    length = state["text_input_preedit_length"]
    if length > 4095:
        fail(f"NekoEdit reported an out-of-bounds preedit length: {length}")
    raw = os.pread(memory_fd, length, addresses["text_input_preedit_buffer"])
    if len(raw) != length:
        fail(f"could not read complete preedit buffer: expected {length}, got {len(raw)}")
    try:
        return raw.decode("utf-8", errors="strict")
    except UnicodeDecodeError as error:
        fail(f"NekoEdit exposed invalid UTF-8 in its committed preedit state: {error}")


def wait_preedit(
    memory_fd: int,
    addresses: dict[str, int],
    expected: str,
    *,
    timeout: float = 6.0,
) -> dict[str, int]:
    deadline = time.monotonic() + timeout
    state: dict[str, int] = {}
    actual = ""
    while time.monotonic() < deadline:
        state = read_state(memory_fd, addresses)
        actual = read_preedit(memory_fd, addresses, state)
        if state["doc_length"] != 0:
            fail(
                "IBus committed document bytes before the explicit hex-sequence "
                f"terminator; state={state}, preedit={actual!r}"
            )
        if actual == expected:
            return state
        time.sleep(0.025)
    fail(
        f"live IBus preedit did not reach {expected!r}; "
        f"observed {actual!r}, state={state}"
    )


def wait_document_commit(
    memory_fd: int, addresses: dict[str, int], expected_length: int
) -> dict[str, int]:
    deadline = time.monotonic() + 6.0
    state: dict[str, int] = {}
    actual_preedit = ""
    while time.monotonic() < deadline:
        state = read_state(memory_fd, addresses)
        actual_preedit = read_preedit(memory_fd, addresses, state)
        if state["doc_length"] == expected_length and actual_preedit == "":
            return state
        time.sleep(0.025)
    fail(
        "live IBus commit was not applied to the document buffer; "
        f"expected_length={expected_length}, state={state}, "
        f"preedit={actual_preedit!r}"
    )


def require_ibus_engine(expected: str) -> None:
    result = subprocess.run(
        ["ibus", "engine"],
        check=True,
        capture_output=True,
        text=True,
        timeout=5,
    )
    actual = result.stdout.strip()
    if actual != expected:
        fail(f"GNOME Shell selected IBus engine {actual!r}, expected {expected!r}")


def exercise_live_ibus_preedit_commit(
    memory_fd: int, addresses: dict[str, int], document: Path
) -> None:
    # GNOME Shell's IBus Simple engine supports the standard Ctrl+Shift+U
    # Unicode entry path when IBUS_ENABLE_CTRL_SHIFT_U is enabled for its
    # daemon. Releasing the modifiers immediately after U uses the engine's
    # documented modifier-dropped form, so hex digits are sent unmodified.
    require_ibus_engine("xkb:us:intl:eng")
    send_key(65507, True)  # Control_L
    send_key(65505, True)  # Shift_L
    send_keysym(85)        # uppercase U
    send_key(65505, False)
    send_key(65507, False)
    wait_input_idle()
    wait_preedit(memory_fd, addresses, "u")

    digits = ""
    for character in "1F600":
        send_keysym(ord(character))
        wait_input_idle()
        digits += character
        wait_preedit(memory_fd, addresses, "u" + digits)

    # Backspace is handled inside the IBus composition buffer. It must update
    # the live preedit rather than deleting bytes from NekoEdit's document.
    send_keysym(65288)  # BackSpace
    wait_input_idle()
    wait_preedit(memory_fd, addresses, "u1F60")

    send_keysym(ord("0"))
    wait_input_idle()
    wait_preedit(memory_fd, addresses, "u1F600")

    # Return terminates the IBus hex sequence and emits commit-text. GNOME
    # Shell translates that into text-input-v3 commit_string + done.
    send_keysym(65293)  # Return
    wait_input_idle()
    wait_document_commit(memory_fd, addresses, 4)

    # The editor's default Save confirmation is part of the real input path.
    send_shortcut(65507, 115)  # Ctrl+S
    send_keysym(65293)         # Enter accepts confirmation
    wait_input_idle()

    expected = "\U0001f600".encode("utf-8")
    deadline = time.monotonic() + 6.0
    while time.monotonic() < deadline:
        if document.read_bytes() == expected:
            print(
                "PASS: live IBus Simple engine delivered preedit updates, "
                "Backspace correction, and U+1F600 commit through Mutter "
                "text-input-v3; confirmed save preserved exact UTF-8 bytes."
            )
            return
        time.sleep(0.05)
    fail(
        "live IBus commit/save produced unexpected document bytes: "
        + repr(document.read_bytes())
    )


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
                    exercise_live_ibus_preedit_commit(
                        memory_fd, addresses, document
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
