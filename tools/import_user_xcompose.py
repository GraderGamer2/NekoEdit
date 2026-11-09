#!/usr/bin/env python3
"""Import a bounded, offline subset of a user XCompose file into NLP1 JSON."""
from __future__ import annotations

import argparse
import codecs
import json
import os
import re
import sys
import tempfile
from pathlib import Path
from typing import Any

from compose_pack import encode_pack, locale_tag
from import_xcompose import DEAD_KEY_MARKS, parse_keysym_definitions

MAX_FILE_BYTES = 512 * 1024
MAX_TOTAL_BYTES = 4 * 1024 * 1024
MAX_UNIQUE_FILES = 32
MAX_FILE_EXPANSIONS = 64
MAX_INCLUDE_DEPTH = 16
MAX_LINE_BYTES = 64 * 1024
MAX_RECORDS = 32_768
MAX_INPUTS = 4
MAX_OUTPUTS = 8

_ALLOWED_ENCODINGS = {
    "ascii", "cp1252", "iso8859-1", "latin-1", "utf-8", "utf-8-sig",
}
_KEY_TOKEN = re.compile(r"<([^<>]+)>")
_UNICODE_KEYSYM = re.compile(r"U([0-9A-Fa-f]{4,6})\Z")
_SYMBOL_RESULT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*\Z")


def _valid_scalar(value: int) -> bool:
    return (
        isinstance(value, int)
        and not isinstance(value, bool)
        and 0 < value <= 0x10FFFF
        and not 0xD800 <= value <= 0xDFFF
    )


def _strip_comment(line: str) -> str:
    """Remove a # comment only when it occurs outside a quoted string."""
    quoted = False
    escaped = False
    for index, char in enumerate(line):
        if quoted:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                quoted = False
        elif char == '"':
            quoted = True
        elif char == "#":
            return line[:index]
    return line


def _find_unquoted_colon(line: str) -> int:
    quoted = False
    escaped = False
    for index, char in enumerate(line):
        if quoted:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                quoted = False
        elif char == '"':
            quoted = True
        elif char == ":":
            return index
    return -1


def _decode_quoted(
    text: str,
    encoding: str,
    *,
    allow_unicode_escapes: bool = True,
) -> tuple[str, int]:
    """Decode one quoted XCompose string and return (value, end_offset).

    Octal and hexadecimal escapes contribute encoded bytes, which are decoded
    with the selected source encoding. \u and \U are accepted as convenient
    Unicode-scalar extensions for user files.
    """
    if not text.startswith('"'):
        raise ValueError("expected a double-quoted string")

    chunks: list[str] = []
    byte_buffer = bytearray()
    index = 1

    def flush_bytes() -> None:
        if byte_buffer:
            try:
                chunks.append(bytes(byte_buffer).decode(encoding, errors="strict"))
            except UnicodeDecodeError as exc:
                raise ValueError(
                    f"escaped bytes are not valid {encoding} text"
                ) from exc
            byte_buffer.clear()

    def append_character(char: str) -> None:
        try:
            byte_buffer.extend(char.encode(encoding, errors="strict"))
        except UnicodeEncodeError as exc:
            raise ValueError(
                f"character U+{ord(char):04X} cannot be represented in {encoding}"
            ) from exc

    simple_escapes = {
        '"': '"',
        "\\": "\\",
        "'": "'",
        "a": "\a",
        "b": "\b",
        "f": "\f",
        "n": "\n",
        "r": "\r",
        "t": "\t",
        "v": "\v",
    }

    while index < len(text):
        char = text[index]
        if char == '"':
            flush_bytes()
            return "".join(chunks), index + 1
        if char != "\\":
            append_character(char)
            index += 1
            continue

        index += 1
        if index >= len(text):
            raise ValueError("trailing backslash in quoted string")
        escaped = text[index]

        if escaped in simple_escapes:
            append_character(simple_escapes[escaped])
            index += 1
            continue

        if escaped in "01234567":
            end = index + 1
            while end < len(text) and end < index + 3 and text[end] in "01234567":
                end += 1
            value = int(text[index:end], 8)
            if value > 0xFF:
                raise ValueError("octal string escape exceeds one byte")
            byte_buffer.append(value)
            index = end
            continue

        if escaped == "x":
            end = index + 1
            while (
                end < len(text)
                and end < index + 3
                and text[end] in "0123456789abcdefABCDEF"
            ):
                end += 1
            if end == index + 1:
                raise ValueError("hexadecimal string escape has no digits")
            byte_buffer.append(int(text[index + 1:end], 16))
            index = end
            continue

        if escaped in {"u", "U"} and allow_unicode_escapes:
            digits = 4 if escaped == "u" else 8
            end = index + 1 + digits
            raw = text[index + 1:end]
            if len(raw) != digits or not re.fullmatch(r"[0-9A-Fa-f]+", raw):
                raise ValueError("malformed Unicode string escape")
            value = int(raw, 16)
            if not _valid_scalar(value):
                raise ValueError(f"Unicode escape U+{value:04X} is not a scalar")
            flush_bytes()
            chunks.append(chr(value))
            index = end
            continue

        raise ValueError(f"unsupported string escape: \\{escaped}")

    raise ValueError("unterminated quoted string")


def _keysym_scalar(name: str, keysyms: dict[str, int]) -> int:
    unicode_match = _UNICODE_KEYSYM.fullmatch(name)
    if unicode_match:
        value = int(unicode_match.group(1), 16)
        return value if _valid_scalar(value) else 0
    if len(name) == 1 and 0x20 <= ord(name) <= 0x7E:
        return ord(name)
    return keysyms.get(name, 0)


def _is_modifier_residue(value: str) -> bool:
    """Recognize the XCompose modifier qualifiers that NLP1 cannot encode."""
    residue = value.strip()
    if not residue:
        return False
    if re.fullmatch(r"None", residue):
        return True
    if not re.fullmatch(r"[!~\[\]\sA-Za-z]+", residue):
        return False
    words = re.findall(r"[A-Za-z]+", residue)
    allowed = {"Ctrl", "Lock", "Caps", "Shift", "Alt", "Meta"}
    return bool(words) and all(word in allowed for word in words)


def _parse_events(
    left: str,
    stats: dict[str, int],
    source: Path,
    line_number: int,
) -> list[str] | None:
    matches = list(_KEY_TOKEN.finditer(left))
    if not matches:
        raise ValueError(f"{source}:{line_number}: expected XCompose <keysym> events")

    residue_parts: list[str] = []
    cursor = 0
    names: list[str] = []
    for match in matches:
        residue_parts.append(left[cursor:match.start()])
        names.append(match.group(1).strip())
        cursor = match.end()
    residue_parts.append(left[cursor:])
    residue = "".join(residue_parts)
    if residue.strip():
        if _is_modifier_residue(residue):
            stats["modifier_rules_skipped"] += 1
            return None
        raise ValueError(
            f"{source}:{line_number}: unsupported event syntax outside <keysym> tokens"
        )
    if any(not name or any(char.isspace() for char in name) for name in names):
        raise ValueError(f"{source}:{line_number}: malformed keysym token")
    return names


def _parse_result(
    right: str,
    keysyms: dict[str, int],
    encoding: str,
    stats: dict[str, int],
    source: Path,
    line_number: int,
) -> tuple[int, ...] | None:
    value = right.strip()
    if not value:
        raise ValueError(f"{source}:{line_number}: missing XCompose result")

    if value.startswith('"'):
        output_text, end = _decode_quoted(value, encoding)
        suffix = value[end:].strip()
        if suffix and not _SYMBOL_RESULT.fullmatch(suffix) and not _UNICODE_KEYSYM.fullmatch(suffix):
            raise ValueError(
                f"{source}:{line_number}: expected at most one result keysym after the string"
            )
        # NekoEdit consumes text, not an X11 keysym event. When a quoted
        # string is present it is authoritative; the optional keysym suffix
        # is intentionally not emitted into the editor.
        outputs = tuple(ord(char) for char in output_text)
    else:
        if not _SYMBOL_RESULT.fullmatch(value) and not _UNICODE_KEYSYM.fullmatch(value):
            raise ValueError(f"{source}:{line_number}: unsupported XCompose result syntax")
        scalar = _keysym_scalar(value, keysyms)
        if not _valid_scalar(scalar):
            stats["unsupported_result"] += 1
            return None
        outputs = (scalar,)

    if not outputs or any(not _valid_scalar(scalar) for scalar in outputs):
        stats["invalid_output"] += 1
        return None
    if len(outputs) > MAX_OUTPUTS:
        stats["too_long_output"] += 1
        return None
    return outputs


class ComposeImporter:
    """Bounded XCompose reader; includes are restricted to explicit roots."""

    def __init__(
        self,
        *,
        keysyms: dict[str, int],
        locale: str,
        home_root: Path,
        system_root: Path,
        locale_compose: Path | None,
        encoding: str = "utf-8",
    ) -> None:
        self.keysyms = keysyms
        self.locale = locale_tag(locale)
        self.home_root = home_root
        self.system_root = system_root
        self.locale_compose = locale_compose
        self.encoding = codecs.lookup(encoding).name
        if self.encoding not in {
            codecs.lookup(name).name for name in _ALLOWED_ENCODINGS
        }:
            raise ValueError(f"unsupported source encoding: {encoding!r}")

        self.rules: dict[tuple[int, tuple[int, ...]], tuple[int, ...]] = {}
        self.active_paths: list[Path] = []
        self.unique_paths: set[Path] = set()
        self.expansions = 0
        self.total_bytes = 0
        self.stats = {
            "include_directives": 0,
            "rules_seen": 0,
            "rules_imported": 0,
            "rule_overrides": 0,
            "dropped_shorter_prefix_rules": 0,
            "unsupported_lead": 0,
            "unsupported_input": 0,
            "unsupported_result": 0,
            "modifier_rules_skipped": 0,
            "short_sequence": 0,
            "too_long_input": 0,
            "too_long_output": 0,
            "invalid_output": 0,
        }

    @staticmethod
    def _canonical_root(path: Path, label: str) -> Path:
        try:
            root = path.expanduser().resolve(strict=True)
        except OSError as exc:
            raise ValueError(f"{label} root is unavailable: {path}") from exc
        if not root.is_dir():
            raise ValueError(f"{label} root is not a directory: {root}")
        return root

    def _resolve_include(self, specifier: str, source: Path, line_number: int) -> Path:
        if specifier == "%L":
            if self.locale_compose is None:
                raise ValueError(
                    f"{source}:{line_number}: include %L needs --locale-compose"
                )
            root = self._canonical_root(self.system_root, "system Compose")
            candidate = self.locale_compose.expanduser()
            try:
                resolved = candidate.resolve(strict=True)
            except OSError as exc:
                raise ValueError(
                    f"{source}:{line_number}: locale Compose file is unavailable: {candidate}"
                ) from exc
            if not resolved.is_relative_to(root):
                raise ValueError(
                    f"{source}:{line_number}: %L resolves outside --system-root"
                )
            if not resolved.is_file():
                raise ValueError(f"{source}:{line_number}: %L is not a regular file")
            return resolved

        if specifier.startswith("%H/"):
            root_path = self._canonical_root(self.home_root, "home")
            suffix = specifier[3:]
            label = "%H"
        elif specifier.startswith("%S/"):
            root_path = self._canonical_root(self.system_root, "system Compose")
            suffix = specifier[3:]
            label = "%S"
        else:
            raise ValueError(
                f"{source}:{line_number}: unsupported include path {specifier!r}; "
                "use %H/..., %S/..., or exact %L"
            )

        relative = Path(suffix)
        if (
            relative.is_absolute()
            or not relative.parts
            or any(part in {"", ".", ".."} for part in relative.parts)
            or "%" in suffix
            or "$" in suffix
            or "~" in suffix
        ):
            raise ValueError(
                f"{source}:{line_number}: unsafe {label} include path {suffix!r}"
            )
        candidate = root_path / relative
        try:
            resolved = candidate.resolve(strict=True)
        except OSError as exc:
            raise ValueError(
                f"{source}:{line_number}: include file is unavailable: {candidate}"
            ) from exc
        if not resolved.is_relative_to(root_path):
            raise ValueError(
                f"{source}:{line_number}: include resolves outside the {label} root"
            )
        if not resolved.is_file():
            raise ValueError(f"{source}:{line_number}: include is not a regular file")
        return resolved

    def _parse_file(self, path: Path, depth: int) -> None:
        if depth > MAX_INCLUDE_DEPTH:
            raise ValueError(
                f"include depth exceeds the {MAX_INCLUDE_DEPTH}-level limit at {path}"
            )
        if path in self.active_paths:
            chain = " -> ".join(str(item) for item in (*self.active_paths, path))
            raise ValueError(f"XCompose include cycle detected: {chain}")
        self.expansions += 1
        if self.expansions > MAX_FILE_EXPANSIONS:
            raise ValueError(
                f"include expansion count exceeds {MAX_FILE_EXPANSIONS}"
            )
        if path not in self.unique_paths:
            self.unique_paths.add(path)
            if len(self.unique_paths) > MAX_UNIQUE_FILES:
                raise ValueError(f"more than {MAX_UNIQUE_FILES} unique Compose files")
        try:
            with path.open("rb") as stream:
                raw = stream.read(MAX_FILE_BYTES + 1)
        except OSError as exc:
            raise ValueError(f"cannot read Compose file {path}: {exc}") from exc
        if len(raw) > MAX_FILE_BYTES:
            raise ValueError(
                f"{path}: file exceeds the {MAX_FILE_BYTES}-byte per-file limit"
            )
        self.total_bytes += len(raw)
        if self.total_bytes > MAX_TOTAL_BYTES:
            raise ValueError(
                f"expanded Compose input exceeds the {MAX_TOTAL_BYTES}-byte total limit"
            )
        try:
            text = raw.decode(self.encoding, errors="strict")
        except UnicodeDecodeError as exc:
            raise ValueError(f"{path}: input is not valid {self.encoding}") from exc
        if "\0" in text:
            raise ValueError(f"{path}: NUL bytes are not allowed")

        self.active_paths.append(path)
        try:
            for line_number, original_line in enumerate(text.splitlines(), 1):
                if len(original_line.encode(self.encoding)) > MAX_LINE_BYTES:
                    raise ValueError(
                        f"{path}:{line_number}: line exceeds {MAX_LINE_BYTES} bytes"
                    )
                line = _strip_comment(original_line).strip()
                if not line or line.startswith("XCOMM"):
                    continue

                if line == "include" or line.startswith("include "):
                    match = re.fullmatch(
                        r'include\s+("(?:\\.|[^"\\])*")\s*', line
                    )
                    if not match:
                        raise ValueError(
                            f"{path}:{line_number}: malformed include directive"
                        )
                    include_value, end = _decode_quoted(
                        match.group(1), self.encoding, allow_unicode_escapes=False
                    )
                    if end != len(match.group(1)):
                        raise ValueError(
                            f"{path}:{line_number}: malformed include path"
                        )
                    self.stats["include_directives"] += 1
                    target = self._resolve_include(include_value, path, line_number)
                    self._parse_file(target, depth + 1)
                    continue

                colon = _find_unquoted_colon(line)
                if colon < 0:
                    raise ValueError(
                        f"{path}:{line_number}: expected an include or Compose rule"
                    )
                self.stats["rules_seen"] += 1
                names = _parse_events(line[:colon], self.stats, path, line_number)
                if names is None:
                    continue
                if not names:
                    raise ValueError(f"{path}:{line_number}: empty event sequence")

                if names[0] == "Multi_key":
                    kind = 0
                    following = names[1:]
                    if len(following) < 2:
                        self.stats["short_sequence"] += 1
                        continue
                    if len(following) > MAX_INPUTS:
                        self.stats["too_long_input"] += 1
                        continue
                    input_values: list[int] = []
                elif names[0] in DEAD_KEY_MARKS:
                    kind = 1
                    following = names[1:]
                    if not following:
                        self.stats["short_sequence"] += 1
                        continue
                    if len(following) != 1:
                        self.stats["too_long_input"] += 1
                        continue
                    input_values = [DEAD_KEY_MARKS[names[0]]]
                else:
                    self.stats["unsupported_lead"] += 1
                    continue

                unsupported = False
                for name in following:
                    scalar = _keysym_scalar(name, self.keysyms)
                    if not _valid_scalar(scalar):
                        self.stats["unsupported_input"] += 1
                        unsupported = True
                        break
                    input_values.append(scalar)
                if unsupported:
                    continue

                outputs = _parse_result(
                    line[colon + 1:],
                    self.keysyms,
                    self.encoding,
                    self.stats,
                    path,
                    line_number,
                )
                if outputs is None:
                    continue
                identity = (kind, tuple(input_values))
                if identity in self.rules:
                    self.stats["rule_overrides"] += 1
                self.rules[identity] = outputs
                self.stats["rules_imported"] += 1
                if len(self.rules) > MAX_RECORDS:
                    raise ValueError(f"more than {MAX_RECORDS} unique Compose records")
        finally:
            self.active_paths.pop()

    def import_file(self, input_path: Path) -> dict[str, Any]:
        try:
            root = input_path.expanduser().resolve(strict=True)
        except OSError as exc:
            raise ValueError(f"input Compose file is unavailable: {input_path}") from exc
        if not root.is_file():
            raise ValueError(f"input Compose path is not a regular file: {root}")
        self._parse_file(root, 0)

        dropped: set[tuple[int, tuple[int, ...]]] = set()
        for kind, sequence in self.rules:
            for length in range(2, len(sequence)):
                prefix = (kind, sequence[:length])
                if prefix in self.rules:
                    dropped.add(prefix)
        for prefix in dropped:
            del self.rules[prefix]
        self.stats["dropped_shorter_prefix_rules"] = len(dropped)

        records = [
            {
                "kind": "multi_key" if kind == 0 else "dead_key",
                "input": list(sequence),
                "output": list(output),
            }
            for (kind, sequence), output in sorted(self.rules.items())
        ]
        if not records:
            raise ValueError("no supported Unicode Compose rules were imported")

        return {
            "locale": self.locale,
            "source": {
                "type": "user_xcompose",
                "format": "XCompose(5) bounded text-rule subset",
                "encoding": self.encoding,
                "import_policy": (
                    "Read the selected file and depth-first includes from explicit %H, %S, "
                    "and %L roots; import unqualified Multi_key and recognized dead-key "
                    "rules with Unicode-scalar inputs; later identical rules override earlier "
                    "ones; drop shorter same-kind prefixes; emit text-only Unicode results."
                ),
            },
            "statistics": {
                "files_read": len(self.unique_paths),
                "file_expansions": self.expansions,
                "total_bytes_read": self.total_bytes,
                "final_rules": len(records),
                **self.stats,
            },
            "sequences": records,
        }


def _atomic_write(path: Path, text: str) -> None:
    path = path.expanduser()
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{path.name}.", suffix=".tmp", dir=path.parent
    )
    temporary = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="\n") as stream:
            stream.write(text)
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temporary, 0o600)
        os.replace(temporary, path)
    except Exception:
        try:
            temporary.unlink()
        except FileNotFoundError:
            pass
        raise


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, type=Path, help="selected .XCompose file")
    parser.add_argument("--locale", required=True, help="locale tag for the generated NLP1 JSON")
    parser.add_argument("--output", required=True, type=Path, help="output JSON path")
    parser.add_argument(
        "--keysymdef",
        type=Path,
        help="optional X.Org keysymdef.h for named non-ASCII keysyms",
    )
    parser.add_argument(
        "--home",
        type=Path,
        default=Path.home(),
        help="allowlisted root for %%H includes (default: home directory)",
    )
    parser.add_argument(
        "--system-root",
        type=Path,
        default=Path("/usr/share/X11/locale"),
        help="allowlisted root for %%S and %%L includes",
    )
    parser.add_argument(
        "--locale-compose",
        type=Path,
        help="explicit system Compose file used by an exact include %%L",
    )
    parser.add_argument(
        "--encoding",
        default="utf-8",
        choices=sorted(_ALLOWED_ENCODINGS),
        help="source text and octal/hex byte-escape encoding (default: utf-8)",
    )
    args = parser.parse_args(argv)

    try:
        keysyms: dict[str, int] = {}
        if args.keysymdef is not None:
            keysyms = parse_keysym_definitions(
                args.keysymdef.read_text(encoding="utf-8")
            )
        importer = ComposeImporter(
            keysyms=keysyms,
            locale=args.locale,
            home_root=args.home,
            system_root=args.system_root,
            locale_compose=args.locale_compose,
            encoding=args.encoding,
        )
        document = importer.import_file(args.input)
        # Reuse the release pack validator so the generated JSON cannot contain
        # records the freestanding NLP1 loader would reject.
        encode_pack(document)
        encoded = json.dumps(document, ensure_ascii=True, indent=2) + "\n"
        _atomic_write(args.output, encoded)
    except (OSError, UnicodeError, ValueError) as exc:
        print(f"import_user_xcompose.py: {exc}", file=sys.stderr)
        return 1

    stats = document["statistics"]
    print(
        f"wrote {stats['final_rules']} {document['locale']} rules from "
        f"{stats['files_read']} files ({stats['include_directives']} includes; "
        f"{stats['rule_overrides']} overrides; "
        f"{stats['dropped_shorter_prefix_rules']} shorter prefixes dropped)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
