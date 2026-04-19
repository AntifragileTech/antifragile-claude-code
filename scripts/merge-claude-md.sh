#!/usr/bin/env bash
#
# ╔═══════════════════════════════════════════════════════════════════╗
# ║  CLAUDE.md MERGE — SAFETY CONTRACT                                ║
# ╠═══════════════════════════════════════════════════════════════════╣
# ║  NEVER:                                                           ║
# ║   • Overwrite the file wholesale                                  ║
# ║   • Modify any existing ## section's content                      ║
# ║   • Remove user's custom sections                                 ║
# ║   • Change header order of existing sections                      ║
# ║   • Deduplicate by content — only by ## header match              ║
# ║                                                                   ║
# ║  ALWAYS:                                                          ║
# ║   • Create a timestamped backup before ANY write                  ║
# ║   • Check every ## section header already present locally         ║
# ║   • Only APPEND sections whose header does NOT exist locally      ║
# ║   • Preserve all user's custom sections (any header we don't have)║
# ║   • Exit 0 with "no changes" message if everything already there  ║
# ║                                                                   ║
# ║  User's own learnings under ## My Team Rules or ## John's Notes   ║
# ║  or ANY header not in our canonical sources → left completely     ║
# ║  untouched, permanently.                                          ║
# ╚═══════════════════════════════════════════════════════════════════╝
#
# Antifragile Claude Code — CLAUDE.md Smart Merge
# Merges ## sections from assets/claude-md/*-global.md into ~/.claude/CLAUDE.md
# Safe to re-run — idempotent.
# Created: 07:24 19-Apr-2026

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

say() { echo -e "${BLUE}[claude-md]${NC} $*"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="$REPO_ROOT/assets/claude-md"
MACHINES_DIR="$REPO_ROOT/assets/machines"
DST="$HOME/.claude/CLAUDE.md"

if [ ! -d "$SRC_DIR" ]; then
  say "No assets/claude-md/ directory found — skipping merge"
  exit 0
fi

mkdir -p "$HOME/.claude"
[ -f "$DST" ] || touch "$DST"

# Backup is created INSIDE Python — only if we're actually going to write.
# This avoids cluttering ~/.claude/ with useless backups on no-op runs.
export REPO_ROOT
python3 << 'PYEOF'
import re, os, json
from pathlib import Path

HOME = Path.home()
repo_env = os.environ.get("REPO_ROOT")
if not repo_env:
    print("  ERROR: REPO_ROOT not set — cannot locate source files")
    raise SystemExit(1)
REPO = Path(repo_env)
SRC_DIR = REPO / "assets" / "claude-md"
MACHINES = REPO / "assets" / "machines"
DST = HOME / ".claude" / "CLAUDE.md"

# Order sources by last_push timestamp (newest first)
sources = []
for src in sorted(SRC_DIR.glob("*-global.md")):
    # derive hostname from filename e.g. M2-Max-global.md -> M2-Max
    name = src.stem.replace("-global", "")
    ts_file = MACHINES / f"{name}.json"
    ts = ""
    if ts_file.exists():
        try:
            ts = json.loads(ts_file.read_text()).get("last_push", "")
        except Exception:
            pass
    sources.append((ts, name, src))
# Newest first
sources.sort(key=lambda x: x[0], reverse=True)

if not sources:
    print("  No *-global.md sources in repo — nothing to merge")
    raise SystemExit(0)

# Read local CLAUDE.md
local_content = DST.read_text() if DST.exists() else ""

# Pattern to split any markdown by top-level ## sections
SECTION_RE = re.compile(r'^(##\s+.+)$', re.MULTILINE)

def extract_sections(text):
    """Return list of (header_line, section_body_including_header)."""
    parts = SECTION_RE.split(text)
    # parts: [prelude, header1, body1, header2, body2, ...]
    sections = []
    i = 1
    while i < len(parts):
        header = parts[i].strip()
        body = parts[i+1] if i+1 < len(parts) else ""
        sections.append((header, header + "\n" + body))
        i += 2
    return sections, parts[0] if parts else ""

local_sections, local_prelude = extract_sections(local_content)
local_headers = {h for h, _ in local_sections}

# Union-merge from all sources, newest first
added = []
for ts, name, src in sources:
    src_text = src.read_text()
    src_sections, _ = extract_sections(src_text)
    for header, block in src_sections:
        if header not in local_headers:
            local_sections.append((header, block))
            local_headers.add(header)
            added.append((name, header))

# Rebuild file
out = local_prelude
if not out.endswith("\n"):
    out += "\n"
for _, block in local_sections:
    if not block.endswith("\n\n"):
        block = block.rstrip() + "\n\n"
    out += block

if added:
    # Only backup when we're actually changing something
    import shutil
    from datetime import datetime
    ts = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup = HOME / ".claude" / f"CLAUDE.md.backup-{ts}"
    shutil.copy2(DST, backup)
    print(f"  Backup: {backup}")
    DST.write_text(out)
    print(f"  Merged {len(added)} section(s):")
    for src_name, hdr in added:
        print(f"    + {hdr[:80]} (from {src_name})")
else:
    print("  All sections already present — no changes")

print(f"  Final: {len(DST.read_text().splitlines())} lines, {len(local_sections)} sections")
PYEOF

say "CLAUDE.md merge complete."
