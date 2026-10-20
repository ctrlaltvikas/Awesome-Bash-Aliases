#!/usr/bin/env python3
"""
Awesome Bash Aliases — Metadata Parser & Validator
Extracts standardized JSDoc-style metadata comment blocks from bash alias files
and generates a parsing-friendly JSON manifest for downstream web applications.
"""

import sys
import glob
import re
import json
from pathlib import Path

# Match standardized JSDoc Bash metadata header followed immediately by alias or function
PATTERN = re.compile(
    r'^# @name:\s*(.+)\n'
    r'^# @category:\s*(.+)\n'
    r'^# @description:\s*(.+)\n'
    r'^# @os:\s*(.+)\n'
    r'^(?:alias\s+([^=\s]+)=(.*?)$|([a-zA-Z0-9_\-\.]+)\s*\(\)\s*\{)',
    re.MULTILINE
)

def parse_metadata(alias_dir="aliases"):
    files = sorted(glob.glob(f"{alias_dir}/*.aliases.bash"))
    if not files:
        print(f"Error: No alias files found in '{alias_dir}'", file=sys.stderr)
        return []

    entries = []
    for filepath in files:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        for match in PATTERN.finditer(content):
            name = match.group(1).strip()
            category = match.group(2).strip()
            description = match.group(3).strip()
            os_target = match.group(4).strip()
            alias_name = match.group(5)
            alias_cmd = match.group(6)
            func_name = match.group(7)

            item_type = "alias" if alias_name else "function"
            command_str = alias_cmd.strip("'\"") if alias_cmd else None

            entries.append({
                "name": name,
                "category": category,
                "description": description,
                "os": os_target,
                "type": item_type,
                "command": command_str,
                "file": Path(filepath).as_posix()
            })

    return entries

def main():
    entries = parse_metadata()
    if not entries:
        sys.exit(1)

    print(f"Successfully extracted {len(entries)} items across {len(set(e['file'] for e in entries))} files.")

    # Write output to metadata.json in repo root
    output_path = Path("metadata.json")
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(entries, f, indent=2)

    print(f"JSON manifest generated at: {output_path}")

if __name__ == "__main__":
    main()
