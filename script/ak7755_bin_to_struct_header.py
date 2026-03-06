#!/usr/bin/env python3

import argparse
import os
import re
import sys


def sanitize_c_identifier(name: str) -> str:
    sanitized = re.sub(r"[^0-9a-zA-Z_]", "_", name)
    if not sanitized:
        sanitized = "firmware_blob"
    if sanitized[0].isdigit():
        sanitized = f"_{sanitized}"
    return sanitized


def format_hex_array(data: bytes, bytes_per_line: int = 16) -> str:
    lines = []
    for offset in range(0, len(data), bytes_per_line):
        chunk = data[offset:offset + bytes_per_line]
        line = ", ".join(f"0x{value:02X}" for value in chunk)
        lines.append(f"    {line},")
    if not lines:
        lines.append("    /* empty */")
    return "\n".join(lines)


def generate_c_declaration(bin_path: str, symbol_name: str) -> str:
    with open(bin_path, "rb") as binary_file:
        payload = binary_file.read()

    array_body = format_hex_array(payload)

    return (
        f"/* Auto-generated from: {os.path.basename(bin_path)} */\n"
        f"static const unsigned char {symbol_name}[] = {{\n"
        f"{array_body}\n"
        "};\n\n"
        "static const struct {\n"
        "    const unsigned char *data;\n"
        "    size_t size;\n"
        f"}} {symbol_name}_fw = {{\n"
        f"    .data = {symbol_name},\n"
        f"    .size = sizeof({symbol_name}),\n"
        "};\n"
    )


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Convert firmware .bin to C byte array + struct declaration"
    )
    parser.add_argument("bin_file", help="Input binary file path (e.g. ak7755_pram_data2.bin)")
    parser.add_argument(
        "--name",
        dest="symbol_name",
        help="C symbol name to use (default: input file basename without extension)",
    )
    args = parser.parse_args()

    if not os.path.isfile(args.bin_file):
        print(f"error: file not found: {args.bin_file}", file=sys.stderr)
        return 1

    base_name = os.path.splitext(os.path.basename(args.bin_file))[0]
    symbol_name = sanitize_c_identifier(args.symbol_name or base_name)

    output = generate_c_declaration(args.bin_file, symbol_name)
    print(output, end="")
    return 0


if __name__ == "__main__":
    sys.exit(main())