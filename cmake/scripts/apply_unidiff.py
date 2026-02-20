#!/usr/bin/env python3
import argparse
import re
from pathlib import Path

BEGIN_RE = re.compile(r"^\*\*\* Begin Patch\s*$")
END_RE   = re.compile(r"^\*\*\* End Patch\s*$")
UPDATE_RE = re.compile(r"^\*\*\* Update File:\s*(.+?)\s*$")
HUNK_RE = re.compile(r"^@@\s*$")

def split_lines_keepends(s: str):
    return s.splitlines(True)

def detect_newline(data: str) -> str:
    return "\r\n" if "\r\n" in data else "\n"

def normalize_line(line: str) -> str:
    return line.rstrip("\r\n")

def parse_patchfile(text: str):
    """
    Parses patch in the 'apply_patch' style:

    *** Begin Patch
    *** Update File: path/to/file
    @@
    -old
    +new
     context
    @@
    ...
    *** End Patch
    """
    lines = text.splitlines()
    i = 0

    # Find Begin
    while i < len(lines) and not BEGIN_RE.match(lines[i]):
        i += 1
    if i >= len(lines):
        raise ValueError("Missing '*** Begin Patch'")

    i += 1

    # Find Update File
    while i < len(lines) and not UPDATE_RE.match(lines[i]):
        i += 1
    if i >= len(lines):
        raise ValueError("Missing '*** Update File:'")

    m = UPDATE_RE.match(lines[i])
    file_in_patch = m.group(1).strip()
    i += 1

    hunks = []
    while i < len(lines) and not END_RE.match(lines[i]):
        # Find @@
        while i < len(lines) and not HUNK_RE.match(lines[i]) and not END_RE.match(lines[i]):
            i += 1
        if i >= len(lines) or END_RE.match(lines[i]):
            break
        # consume @@
        i += 1
        hunk_lines = []
        while i < len(lines) and not HUNK_RE.match(lines[i]) and not END_RE.match(lines[i]):
            # valid lines start with ' ', '+', '-'
            if lines[i] and lines[i][0] in (" ", "+", "-"):
                hunk_lines.append(lines[i])
            i += 1
        if hunk_lines:
            hunks.append(hunk_lines)

    if not hunks:
        raise ValueError("No hunks found")

    return file_in_patch, hunks

def apply_hunks_to_file(target_path: Path, hunks):
    data = target_path.read_text(encoding="utf-8", errors="replace")
    nl = detect_newline(data)
    file_lines = [ln + nl for ln in data.splitlines(False)]
    had_trailing_nl = data.endswith("\n") or data.endswith("\r\n")

    def find_block(block, start_at=0):
        # exact match block (list of lines with newline)
        blen = len(block)
        for pos in range(start_at, len(file_lines) - blen + 1):
            if file_lines[pos:pos+blen] == block:
                return pos
        return None

    changed_any = False

    for h in hunks:
        old_block = []
        new_block = []
        for raw in h:
            tag = raw[0]
            content = raw[1:]
            # keep original line text (without trailing newline), re-add nl
            line = normalize_line(content) + nl
            if tag in (" ", "-"):
                old_block.append(line)
            if tag in (" ", "+"):
                new_block.append(line)

        # If old_block matches somewhere, replace with new_block
        pos = find_block(old_block, 0)
        if pos is not None:
            file_lines[pos:pos+len(old_block)] = new_block
            changed_any = True
            continue

        # If new_block already present, treat as already applied
        pos2 = find_block(new_block, 0)
        if pos2 is not None:
            continue

        # fallback: search with relaxed window by using first 3 context lines
        ctx = [l for l in old_block if l and not l.startswith(("+", "-"))]
        # We already expanded tags, so ctx are just lines; but might be too strict.
        # If we can't find, raise.
        preview = "".join(old_block[:8])
        raise RuntimeError("Hunk does not match target file.\nPreview of expected old block:\n" + preview)

    out = "".join(file_lines)
    if not had_trailing_nl and out.endswith(nl):
        out = out[:-len(nl)]

    if changed_any:
        target_path.write_text(out, encoding="utf-8")
        return "applied"
    else:
        return "already applied"

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--patch", required=True)
    ap.add_argument("--file", required=True)
    args = ap.parse_args()

    patch_text = Path(args.patch).read_text(encoding="utf-8", errors="replace")
    _file_in_patch, hunks = parse_patchfile(patch_text)

    target = Path(args.file)
    status = apply_hunks_to_file(target, hunks)
    print(f"Patch: {status}")

if __name__ == "__main__":
    main()