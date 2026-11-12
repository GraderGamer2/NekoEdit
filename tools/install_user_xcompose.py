#!/usr/bin/env python3
"""Install a selected user XCompose file as a private NekoEdit NLP1 pack.

This optional offline host utility never runs from the freestanding editor.
"""
from __future__ import annotations

import argparse
import os
import secrets
import stat
import sys
from pathlib import Path
from typing import Any

from compose_pack import encode_pack, locale_tag
from import_user_xcompose import ComposeImporter
from import_xcompose import parse_keysym_definitions

_DIRECTORY_FLAGS = (
    os.O_RDONLY
    | getattr(os, "O_DIRECTORY", 0)
    | getattr(os, "O_CLOEXEC", 0)
    | getattr(os, "O_NOFOLLOW", 0)
)


def _open_private_child(parent_fd: int, name: str, label: str) -> int:
    """Open or create one owned, non-symlink directory relative to a trusted fd."""
    try:
        os.mkdir(name, mode=0o700, dir_fd=parent_fd)
    except FileExistsError:
        pass

    try:
        descriptor = os.open(name, _DIRECTORY_FLAGS, dir_fd=parent_fd)
    except OSError as exc:
        raise ValueError(f"{label} must be a real directory, not a symlink: {exc}") from exc

    try:
        metadata = os.fstat(descriptor)
        if not stat.S_ISDIR(metadata.st_mode):
            raise ValueError(f"{label} is not a directory")
        if metadata.st_uid != os.getuid():
            raise ValueError(f"{label} is not owned by the current user")
        if stat.S_IMODE(metadata.st_mode) != 0o700:
            os.fchmod(descriptor, 0o700)
        return descriptor
    except Exception:
        os.close(descriptor)
        raise


def _open_locale_directory(home: Path) -> tuple[Path, int]:
    """Return the canonical home and an fd for ~/.nekoedit/locales (0700)."""
    try:
        home_root = home.expanduser().resolve(strict=True)
    except OSError as exc:
        raise ValueError(f"home directory is unavailable: {home}") from exc
    if not home_root.is_dir():
        raise ValueError(f"home path is not a directory: {home_root}")

    try:
        home_fd = os.open(home_root, _DIRECTORY_FLAGS)
    except OSError as exc:
        raise ValueError(f"cannot open home directory safely: {exc}") from exc

    app_fd = -1
    try:
        home_metadata = os.fstat(home_fd)
        if not stat.S_ISDIR(home_metadata.st_mode) or home_metadata.st_uid != os.getuid():
            raise ValueError("home directory must be owned by the current user")
        app_fd = _open_private_child(home_fd, ".nekoedit", "~/.nekoedit")
    finally:
        os.close(home_fd)

    try:
        locale_fd = _open_private_child(app_fd, "locales", "~/.nekoedit/locales")
    finally:
        os.close(app_fd)

    return home_root, locale_fd


def _write_pack_atomic(
    directory_fd: int,
    filename: str,
    payload: bytes,
    *,
    replace: bool,
) -> None:
    """Publish mode-0600 bytes atomically without following the target path."""
    temporary = f".{filename}.{os.getpid()}.{secrets.token_hex(8)}.tmp"
    flags = (
        os.O_WRONLY
        | os.O_CREAT
        | os.O_EXCL
        | getattr(os, "O_CLOEXEC", 0)
        | getattr(os, "O_NOFOLLOW", 0)
    )
    descriptor = os.open(temporary, flags, 0o600, dir_fd=directory_fd)
    try:
        with os.fdopen(descriptor, "wb") as stream:
            descriptor = -1
            stream.write(payload)
            stream.flush()
            os.fchmod(stream.fileno(), 0o600)
            os.fsync(stream.fileno())

        if replace:
            try:
                existing = os.stat(
                    filename, dir_fd=directory_fd, follow_symlinks=False
                )
            except FileNotFoundError:
                pass
            else:
                if not stat.S_ISREG(existing.st_mode):
                    raise ValueError(
                        f"refusing to replace non-regular locale entry: {filename}"
                    )
            os.replace(
                temporary, filename,
                src_dir_fd=directory_fd, dst_dir_fd=directory_fd,
            )
        else:
            # link() is an atomic no-clobber publish; no check-then-overwrite race.
            os.link(
                temporary, filename,
                src_dir_fd=directory_fd, dst_dir_fd=directory_fd,
                follow_symlinks=False,
            )
            os.unlink(temporary, dir_fd=directory_fd)

        os.fsync(directory_fd)
    finally:
        if descriptor >= 0:
            os.close(descriptor)
        try:
            os.unlink(temporary, dir_fd=directory_fd)
        except FileNotFoundError:
            pass


def install_user_xcompose(
    *,
    input_path: Path,
    locale: str,
    home: Path,
    system_root: Path,
    locale_compose: Path | None = None,
    keysymdef: Path | None = None,
    encoding: str = "utf-8",
    replace: bool = False,
) -> tuple[Path, dict[str, Any]]:
    """Import a selected file and atomically install the resulting NLP1 pack."""
    tag = locale_tag(locale)
    keysyms: dict[str, int] = {}
    keysym_path: Path | None = None
    if keysymdef is not None:
        try:
            keysym_path = keysymdef.expanduser().resolve(strict=True)
            keysyms = parse_keysym_definitions(
                keysym_path.read_text(encoding="utf-8")
            )
        except (OSError, UnicodeError, ValueError) as exc:
            raise ValueError(f"cannot read keysym definitions: {exc}") from exc

    importer = ComposeImporter(
        keysyms=keysyms,
        locale=tag,
        home_root=home,
        system_root=system_root,
        locale_compose=locale_compose,
        encoding=encoding,
    )
    document = importer.import_file(input_path)
    payload = encode_pack(document)

    home_root, directory_fd = _open_locale_directory(home)
    filename = f"{tag}.nlp"
    target = home_root / ".nekoedit" / "locales" / filename
    resolved_target = target.resolve(strict=False)
    if resolved_target in importer.unique_paths:
        os.close(directory_fd)
        raise ValueError("installed pack path must not replace an imported Compose source")
    if keysym_path is not None and resolved_target == keysym_path:
        os.close(directory_fd)
        raise ValueError("installed pack path must not replace keysymdef.h")

    try:
        _write_pack_atomic(directory_fd, filename, payload, replace=replace)
    finally:
        os.close(directory_fd)

    return target, document["statistics"]


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, type=Path, help="selected .XCompose file")
    parser.add_argument("--locale", required=True, help="installed locale tag, e.g. custom.UTF-8")
    parser.add_argument(
        "--keysymdef", type=Path,
        help="optional X.Org keysymdef.h for named non-ASCII input keysyms",
    )
    parser.add_argument(
        "--home", type=Path, default=Path.home(),
        help="home root for %H includes and ~/.nekoedit/locales (default: current user)",
    )
    parser.add_argument(
        "--system-root", type=Path, default=Path("/usr/share/X11/locale"),
        help="allowlisted root for %S and %L includes",
    )
    parser.add_argument(
        "--locale-compose", type=Path,
        help="explicit system Compose file used by an exact include %L",
    )
    parser.add_argument(
        "--encoding",
        choices=("ascii", "cp1252", "iso8859-1", "latin-1", "utf-8", "utf-8-sig"),
        default="utf-8",
        help="source text and octal/hex byte-escape encoding (default: utf-8)",
    )
    parser.add_argument(
        "--replace", action="store_true",
        help="atomically replace an existing regular pack with the same locale tag",
    )
    args = parser.parse_args(argv)

    try:
        target, stats = install_user_xcompose(
            input_path=args.input,
            locale=args.locale,
            home=args.home,
            system_root=args.system_root,
            locale_compose=args.locale_compose,
            keysymdef=args.keysymdef,
            encoding=args.encoding,
            replace=args.replace,
        )
    except (OSError, UnicodeError, ValueError) as exc:
        print(f"install_user_xcompose.py: {exc}", file=sys.stderr)
        return 1

    print(
        f"installed {args.locale}: {stats['final_rules']} rules from "
        f"{stats['files_read']} files ({stats['include_directives']} includes; "
        f"{stats['rule_overrides']} overrides) at {target}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
