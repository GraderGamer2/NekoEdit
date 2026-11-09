#!/usr/bin/env python3
"""Unit tests for the NLP1 Compose locale-pack generator."""
from __future__ import annotations
import struct
import sys
import zlib
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/"tools"))
from compose_pack import HEADER_SIZE,MAGIC,RECORD_SIZE,VERSION,encode_pack  # noqa: E402


def rejected(document,reason):
    try: encode_pack(document)
    except ValueError: return
    raise AssertionError("accepted invalid pack input: "+reason)


def main():
    document={"locale":"fr_FR.UTF-8","sequences":[
        {"input":["U+006F","U+0069"],"output":["U+2603","U+FE0F"]},
        {"input":["U+0079","U+0075","U+0069"],"output":["U+2605"]},
        {"input":["U+0077","U+0065","U+0072","U+0074"],"output":["U+1F642"]},
    ]}
    packed=encode_pack(document)
    h=struct.unpack("<8s7I32sI",packed[:HEADER_SIZE])
    if (h[0]!=MAGIC or h[1]!=VERSION or h[2]!=HEADER_SIZE or h[3]!=RECORD_SIZE
        or h[4]!=3 or h[5]!=3*RECORD_SIZE
        or h[6]!=(zlib.crc32(packed[HEADER_SIZE:])&0xffffffff)
        or h[7]!=0 or h[8].split(bytes(1),1)[0]!=b"fr_FR.UTF-8" or h[9]!=0
        or len(packed)!=HEADER_SIZE+h[5]):
        raise AssertionError("NLP1 header or payload mismatch")
    records=[struct.unpack_from("<BBH4I8I",packed,HEADER_SIZE+i*RECORD_SIZE) for i in range(3)]
    # BBH occupies tuple fields 0–2; the four input scalars start at index 3.
    keys=[r[3:3+r[0]] for r in records]
    if keys!=sorted(keys) or [r[1] for r in records]!=[2,1,1]:
        raise AssertionError("pack sorting or output scalar counts are wrong")
    rejected({"locale":"fr_FR","sequences":[
        {"input":[97,98],"output":[65]},{"input":[97,98,99],"output":[66]}]}, "prefix ambiguity")
    rejected({"locale":"fr_FR","sequences":[
        {"input":[97,98],"output":[65]},{"input":[97,98],"output":[66]}]}, "duplicate")
    rejected({"locale":"fr_FR","sequences":[{"input":[0xd800,98],"output":[65]}]}, "surrogate")
    rejected({"locale":"../escape","sequences":[{"input":[97,98],"output":[65]}]}, "path traversal")
    rejected({"locale":"fr_FR","sequences":[{"input":[97,98],"output":[65]*9}]}, "output too long")
    rejected({"locale":"en_US.UTF-8","sequences":[{"input":[97,98],"output":[65]}]}, "built-in locale")
    print("NLP1 locale-pack generator tests passed")


if __name__=="__main__":
    main()
