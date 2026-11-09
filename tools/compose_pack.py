#!/usr/bin/env python3
"""Build validated, data-only NekoEdit Compose locale packs (NLP1)."""
from __future__ import annotations
import argparse
import json
import os
import struct
import sys
import zlib
from pathlib import Path
from typing import Any

MAGIC=b"NEKOLOC1"
VERSION=1
HEADER_SIZE=72
RECORD_SIZE=52
MAX_RECORDS=32768
MAX_PACK_SIZE=2*1024*1024
MAX_INPUTS=4
MAX_OUTPUTS=8


def scalar(value: Any, field: str) -> int:
    if isinstance(value, str):
        token=value.strip()
        if token.upper().startswith("U+"): token=token[2:]
        try: result=int(token,16)
        except ValueError as exc: raise ValueError(f"{field}: invalid scalar {value!r}") from exc
    elif isinstance(value,int) and not isinstance(value,bool):
        result=value
    else: raise ValueError(f"{field}: expected integer or U+ hexadecimal string")
    if result <= 0 or result > 0x10ffff or 0xd800 <= result <= 0xdfff:
        raise ValueError(f"{field}: U+{result:04X} is not a Unicode scalar")
    return result


def locale_tag(value: Any) -> str:
    if not isinstance(value,str): raise ValueError("locale must be a string")
    try: value.encode("ascii")
    except UnicodeEncodeError as exc: raise ValueError("locale must be ASCII") from exc
    allowed="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.@-"
    if not 1 <= len(value) <= 31 or value[0]=="." or value[-1]==".":
        raise ValueError("locale tag must contain 1–31 safe ASCII characters")
    for i,c in enumerate(value):
        if c not in allowed or (c=="." and value[i:i+2]==".."):
            raise ValueError(f"unsafe locale-tag character: {c!r}")
    if value in {"en_US","en_US.UTF-8","C","POSIX"}:
        raise ValueError("built-in en_US does not need an optional pack")
    return value


def normalize(document: Any):
    if not isinstance(document,dict): raise ValueError("JSON root must be an object")
    tag=locale_tag(document.get("locale"))
    entries=document.get("sequences")
    if not isinstance(entries,list) or not 1 <= len(entries) <= MAX_RECORDS:
        raise ValueError(f"sequences must contain 1–{MAX_RECORDS} records")
    records=[]
    seen=set()
    for i,entry in enumerate(entries):
        if not isinstance(entry,dict): raise ValueError(f"sequences[{i}] must be an object")
        ins,outs=entry.get("input"),entry.get("output")
        if not isinstance(ins,list) or not 2 <= len(ins) <= MAX_INPUTS:
            raise ValueError(f"sequences[{i}].input must contain 2–4 scalars")
        if not isinstance(outs,list) or not 1 <= len(outs) <= MAX_OUTPUTS:
            raise ValueError(f"sequences[{i}].output must contain 1–8 scalars")
        key=tuple(scalar(v,f"sequences[{i}].input") for v in ins)
        result=tuple(scalar(v,f"sequences[{i}].output") for v in outs)
        if key in seen: raise ValueError(f"duplicate input sequence {key!r}")
        seen.add(key)
        records.append((key,result))
    records.sort(key=lambda pair:pair[0])
    for previous,current in zip(records,records[1:]):
        a,b=previous[0],current[0]
        if a[:min(len(a),len(b))] == b[:min(len(a),len(b))]:
            raise ValueError(f"prefix-ambiguous input sequences: {a!r}, {b!r}")
    return tag,records


def encode_pack(document: Any) -> bytes:
    tag,records=normalize(document)
    payload=bytearray()
    for inputs,outputs in records:
        ins=inputs+(0,)*(MAX_INPUTS-len(inputs))
        outs=outputs+(0,)*(MAX_OUTPUTS-len(outputs))
        payload.extend(struct.pack("<BBH4I8I",len(inputs),len(outputs),0,*ins,*outs))
    if HEADER_SIZE+len(payload)>MAX_PACK_SIZE:
        raise ValueError("encoded pack exceeds 2 MiB")
    tag_bytes=tag.encode("ascii")
    tag_field=tag_bytes+bytes(32-len(tag_bytes))
    header=struct.pack("<8s7I32sI",MAGIC,VERSION,HEADER_SIZE,RECORD_SIZE,
                       len(records),len(payload),zlib.crc32(payload)&0xffffffff,
                       0,tag_field,0)
    return header+payload


def main(argv=None) -> int:
    parser=argparse.ArgumentParser(description=__doc__)
    sub=parser.add_subparsers(dest="command",required=True)
    build=sub.add_parser("build",help="build a .nlp locale pack")
    build.add_argument("--input",required=True,type=Path)
    build.add_argument("--output",required=True,type=Path)
    args=parser.parse_args(argv)
    try:
        document=json.loads(args.input.read_text(encoding="utf-8"))
        packed=encode_pack(document)
        args.output.parent.mkdir(parents=True,exist_ok=True)
        temporary=args.output.with_name(args.output.name+".tmp")
        try:
            temporary.write_bytes(packed)
            os.replace(temporary,args.output)
        finally:
            try: temporary.unlink()
            except FileNotFoundError: pass
    except (OSError,json.JSONDecodeError,ValueError) as exc:
        print(f"compose_pack.py: {exc}",file=sys.stderr)
        return 1
    print(f"wrote {len(packed)} bytes for {document['locale']} ({len(document['sequences'])} rules)")
    return 0


if __name__=="__main__":
    raise SystemExit(main())
