#!/usr/bin/env bash
# Created: 10:18 08-Apr-2026
# Security Patch — AUTO-FIXES known vulnerabilities in installed skills
# Safe to re-run — idempotent (won't double-patch already-fixed files)
# Uses Python for reliable regex replacements across all .md files
set -euo pipefail

SKILLS_DIR="$HOME/.claude/skills"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "No skills directory found at $SKILLS_DIR — nothing to patch."
  exit 0
fi

echo "🔒 Security Patch — scanning and FIXING all installed skills..."
echo ""

python3 << 'PYTHON_SCRIPT'
import os, re, sys
from pathlib import Path

SKILLS_DIR = Path.home() / ".claude" / "skills"
stats = {"curl_bash": 0, "innerhtml": 0, "real_keys": 0, "break_sys": 0, "chmod777": 0, "wildcard_cors": 0, "files_touched": 0, "files_scanned": 0}
touched_files = set()

def fix_file(filepath, pattern, replacement, stat_key, description):
    """Apply a regex fix to a file. Returns True if changed."""
    try:
        content = filepath.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return False

    new_content, count = pattern.subn(replacement, content)
    if count > 0:
        filepath.write_text(new_content, encoding="utf-8")
        stats[stat_key] += count
        touched_files.add(str(filepath))
        rel = str(filepath).replace(str(SKILLS_DIR) + "/", "")
        print(f"  \033[0;32mFIXED\033[0m: {rel} — {description} ({count}x)")
        return True
    return False

# Collect all scannable files (excluding node_modules, .git, dist, vendor)
EXCLUDE_DIRS = {"node_modules", ".git", "dist", "vendor", "__pycache__", ".factory"}
SCAN_EXTENSIONS = {".md", ".sh", ".ts", ".tsx", ".js", ".jsx", ".py", ".rb", ".go", ".rs", ".yaml", ".yml", ".toml"}

md_files = []
for f in SKILLS_DIR.rglob("*"):
    if not f.is_file():
        continue
    if any(excl in f.parts for excl in EXCLUDE_DIRS):
        continue
    if f.suffix in SCAN_EXTENSIONS:
        md_files.append(f)
stats["files_scanned"] = len(md_files)

# ============================================================
# FIX 1: curl | bash / curl | sh (Remote Code Execution)
# Skip if file already has safety warning near the pattern
# ============================================================
print("--- Fix 1: curl-pipe-bash patterns ---")
curl_pattern = re.compile(
    r'(?<!# )(?<!#\s)(?<!<!-- )'           # not already commented out
    r'(curl\s+[^\n|]*?\|\s*(?:sudo\s+)?(?:ba)?sh)',
    re.MULTILINE
)

for f in md_files:
    try:
        content = f.read_text(encoding="utf-8", errors="replace")
    except Exception:
        continue

    # Skip files that already have safety warnings about curl|bash
    if re.search(r'(Download and inspect|⚠️.*curl|NEVER.*pipe.*curl|download.*inspect.*run)', content, re.IGNORECASE):
        continue

    matches = list(curl_pattern.finditer(content))
    if not matches:
        continue

    new_content = content
    for match in reversed(matches):
        original = match.group(0)
        safe_version = (
            f"# ⚠️ SECURITY: Download and inspect before running:\n"
            f"# {original.strip()}\n"
            f"# Instead: curl -fsSL <url> -o install.sh && cat install.sh && bash install.sh"
        )
        new_content = new_content[:match.start()] + safe_version + new_content[match.end():]

    if new_content != content:
        f.write_text(new_content, encoding="utf-8")
        stats["curl_bash"] += len(matches)
        touched_files.add(str(f))
        rel = str(f).replace(str(SKILLS_DIR) + "/", "")
        print(f"  \033[0;32mFIXED\033[0m: {rel} — curl|bash ({len(matches)}x)")

# ============================================================
# FIX 2: innerHTML = (XSS risk)
# Replace with textContent unless already has DOMPurify/sanitize note
# ============================================================
print("\n--- Fix 2: innerHTML XSS patterns ---")
innerHTML_pattern = re.compile(r'\.innerHTML\s*=')

for f in md_files:
    try:
        content = f.read_text(encoding="utf-8", errors="replace")
    except Exception:
        continue

    if not innerHTML_pattern.search(content):
        continue

    # Skip if file already discusses sanitization
    if re.search(r'(DOMPurify|sanitize|textContent.*instead|⚠️.*innerHTML)', content, re.IGNORECASE):
        continue

    new_content = innerHTML_pattern.sub('.textContent =', content)
    if new_content != content:
        count = len(innerHTML_pattern.findall(content))
        f.write_text(new_content, encoding="utf-8")
        stats["innerhtml"] += count
        touched_files.add(str(f))
        rel = str(f).replace(str(SKILLS_DIR) + "/", "")
        print(f"  \033[0;32mFIXED\033[0m: {rel} — innerHTML→textContent ({count}x)")

# ============================================================
# FIX 3: Real hardcoded API keys (20+ char after prefix)
# Only fix actual keys, not placeholders like sk-... or sk-xxxx
# ============================================================
print("\n--- Fix 3: Hardcoded API keys ---")
key_patterns = [
    (re.compile(r'(=\s*|:\s*|"|\')sk-[a-zA-Z0-9]{20,}'), "OpenAI", "$OPENAI_API_KEY"),
    (re.compile(r'(=\s*|:\s*|"|\')ghp_[a-zA-Z0-9]{20,}'), "GitHub PAT", "$GITHUB_TOKEN"),
    (re.compile(r'(=\s*|:\s*|"|\')AKIA[A-Z0-9]{16,}'), "AWS Access Key", "$AWS_ACCESS_KEY_ID"),
    (re.compile(r'(=\s*|:\s*|"|\')gsk_[a-zA-Z0-9]{20,}'), "Groq", "$GROQ_API_KEY"),
]

for f in md_files:
    try:
        content = f.read_text(encoding="utf-8", errors="replace")
    except Exception:
        continue

    changed = False
    new_content = content
    for pattern, name, env_var in key_patterns:
        matches = list(pattern.finditer(new_content))
        for match in reversed(matches):
            full = match.group(0)
            prefix = match.group(1)  # the = or : or quote
            replacement = f'{prefix}{env_var}'
            new_content = new_content[:match.start()] + replacement + new_content[match.end():]
            changed = True
            stats["real_keys"] += 1

    if changed:
        f.write_text(new_content, encoding="utf-8")
        touched_files.add(str(f))
        rel = str(f).replace(str(SKILLS_DIR) + "/", "")
        print(f"  \033[0;32mFIXED\033[0m: {rel} — hardcoded API keys replaced with env vars")

# ============================================================
# FIX 4: --break-system-packages
# ============================================================
print("\n--- Fix 4: --break-system-packages ---")
break_pattern = re.compile(r'\s*--break-system-packages')

for f in md_files:
    try:
        content = f.read_text(encoding="utf-8", errors="replace")
    except Exception:
        continue

    if '--break-system-packages' not in content:
        continue

    # Skip if file already recommends venv
    if re.search(r'(venv|virtual.*environment|⚠️.*break)', content, re.IGNORECASE):
        continue

    new_content = break_pattern.sub('', content)
    if new_content != content:
        f.write_text(new_content, encoding="utf-8")
        stats["break_sys"] += 1
        touched_files.add(str(f))
        rel = str(f).replace(str(SKILLS_DIR) + "/", "")
        print(f"  \033[0;32mFIXED\033[0m: {rel} — removed --break-system-packages")

# ============================================================
# FIX 5: chmod 777 / world-writable
# ============================================================
print("\n--- Fix 5: chmod 777 ---")
chmod_pattern = re.compile(r'chmod\s+777')

for f in md_files:
    try:
        content = f.read_text(encoding="utf-8", errors="replace")
    except Exception:
        continue

    if not chmod_pattern.search(content):
        continue

    if re.search(r'(❌|WRONG|never.*777|avoid.*777)', content, re.IGNORECASE):
        continue

    new_content = chmod_pattern.sub('chmod 755', content)
    if new_content != content:
        f.write_text(new_content, encoding="utf-8")
        stats["chmod777"] += 1
        touched_files.add(str(f))
        rel = str(f).replace(str(SKILLS_DIR) + "/", "")
        print(f"  \033[0;32mFIXED\033[0m: {rel} — chmod 777→755")

# ============================================================
# FIX 6: Wildcard CORS without warning
# ============================================================
print("\n--- Fix 6: Wildcard CORS ---")
cors_pattern = re.compile(r'Access-Control-Allow-Origin:\s*\*')

for f in md_files:
    try:
        content = f.read_text(encoding="utf-8", errors="replace")
    except Exception:
        continue

    if not cors_pattern.search(content):
        continue

    if re.search(r'(❌|NEVER.*production|avoid.*wildcard|⚠️.*CORS)', content, re.IGNORECASE):
        continue

    new_content = cors_pattern.sub(
        'Access-Control-Allow-Origin: $ALLOWED_ORIGIN  # ⚠️ Never use * in production',
        content
    )
    if new_content != content:
        f.write_text(new_content, encoding="utf-8")
        stats["wildcard_cors"] += 1
        touched_files.add(str(f))
        rel = str(f).replace(str(SKILLS_DIR) + "/", "")
        print(f"  \033[0;32mFIXED\033[0m: {rel} — wildcard CORS replaced")

# ============================================================
# SUMMARY
# ============================================================
stats["files_touched"] = len(touched_files)
total_fixes = sum(v for k, v in stats.items() if k not in ("files_touched", "files_scanned"))

print(f"\n{'='*60}")
print(f"🔒 Security Patch Complete")
print(f"{'='*60}")
print(f"  Files scanned:  {stats['files_scanned']}")
print(f"  Files fixed:    {stats['files_touched']}")
print(f"  Total fixes:    {total_fixes}")
print(f"    curl|bash:    {stats['curl_bash']}")
print(f"    innerHTML:    {stats['innerhtml']}")
print(f"    API keys:     {stats['real_keys']}")
print(f"    break-sys:    {stats['break_sys']}")
print(f"    chmod 777:    {stats['chmod777']}")
print(f"    CORS:         {stats['wildcard_cors']}")
print(f"{'='*60}")

if total_fixes == 0:
    print("✅ All skills are already clean — no patches needed.")
else:
    print(f"✅ {total_fixes} vulnerabilities auto-fixed across {stats['files_touched']} files.")

PYTHON_SCRIPT
