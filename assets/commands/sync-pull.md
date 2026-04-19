# /sync-pull — Pull Latest Config from antifragile-claude-code

Pull latest Claude Code configuration from the shared antifragile-claude-code repo.
Run this BEFORE starting work to get updates from other team members or devices.

## What This Does

1. Clones or pulls the latest antifragile-claude-code repo
2. **Smart syncs** files using per-type strategies (not just additive)
3. Updates changed files while preserving local customizations
4. Runs security patches on all installed skills
5. Reports what was added, updated, and skipped

## Sync Strategy (per file type)

| Type | Strategy | Why |
|------|----------|-----|
| Scripts (.sh) | Smart merge | Protect local edits, add new, update unmodified |
| Commands (.md) | Smart merge | Protect local edits, add new, update unmodified |
| Agents (.md) | Smart merge | Protect local edits, add new, update unmodified |
| Rules (.md) | Smart merge | Protect local edits, add new, update unmodified |
| Skills (.md) | Smart merge | Protect local edits, add new, update unmodified |
| Hooks (.sh) | Smart merge | Protect local edits, add new, update unmodified |
| CLAUDE.md (global) | Section-level smart merge | Merges missing `##` sections — never overwrites existing sections |
| CLAUDE.md (project) | Insights merge only | Only `(Insights ...)` tagged sections are merged |
| settings.json template | NEVER auto-apply | User has own settings |

## Rules (CRITICAL)
- **NEVER delete** local files that don't exist in repo
- **ALL file types use smart merge**: if a file exists locally and was edited since last sync, PROTECT it
- **New files** (exist in repo but not locally): always add
- **Unmodified files** (local matches last sync checksum): safe to update
- **Modified files** (local differs from last sync checksum): PROTECTED — never overwritten
- Checksum manifest (`.sync-manifest.json`) tracks what was last synced to detect local edits

## Steps

### Step 1: Clone or pull latest
```bash
if [ -d /tmp/antifragile-pull/.git ]; then
  cd /tmp/antifragile-pull && git pull --rebase origin master
else
  rm -rf /tmp/antifragile-pull
  git clone https://github.com/AntifragileTech/antifragile-claude-code.git /tmp/antifragile-pull
fi
```

### Step 1b: Ensure external dependencies (brew, gh, jq, node, python3, uv)
Runs `scripts/install-deps.sh` from the cloned repo — idempotent, only installs what's missing.
```bash
if [ -f /tmp/antifragile-pull/scripts/install-deps.sh ]; then
  YES=1 bash /tmp/antifragile-pull/scripts/install-deps.sh || echo "(deps had issues — continuing)"
fi
```

### Step 1c: Full CLAUDE.md section merge (smart, additive-only)
Runs `scripts/merge-claude-md.sh` — merges ANY missing `##` sections from `assets/claude-md/*-global.md` files (all machines' pushed CLAUDE.md content). Backs up before modifying. Never overwrites existing sections.
```bash
if [ -f /tmp/antifragile-pull/scripts/merge-claude-md.sh ]; then
  bash /tmp/antifragile-pull/scripts/merge-claude-md.sh
fi
```

### Step 2: Run smart sync
```bash
python3 << 'SYNC_SCRIPT'
import os, shutil, hashlib, json
from pathlib import Path

HOME = Path.home()
CLAUDE = HOME / ".claude"
REPO = Path("/tmp/antifragile-pull/assets")
MANIFEST_FILE = CLAUDE / ".sync-manifest.json"

# Load or create checksum manifest
# Tracks: { "relative/path": "sha256_at_last_sync" }
manifest = {}
if MANIFEST_FILE.exists():
    try:
        manifest = json.loads(MANIFEST_FILE.read_text())
    except Exception:
        manifest = {}

stats = {"added": 0, "updated": 0, "skipped": 0, "protected": 0}

def sha256(path):
    """Get SHA256 hash of a file."""
    try:
        return hashlib.sha256(Path(path).read_bytes()).hexdigest()
    except Exception:
        return None

def sync_file(src, dst, rel_key, strategy="always_update"):
    """
    Sync a single file from repo to local.
    
    Strategies:
      always_update — overwrite local with repo version (for our authored files)
      smart_merge  — only update if local hasn't been edited since last sync
    """
    src, dst = Path(src), Path(dst)
    
    if not src.exists():
        return
    
    src_hash = sha256(src)
    dst_hash = sha256(dst) if dst.exists() else None
    last_synced_hash = manifest.get(rel_key)
    
    # Case 1: File doesn't exist locally — always add
    if not dst.exists():
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        manifest[rel_key] = src_hash
        stats["added"] += 1
        print(f"  + {rel_key} (NEW)")
        return
    
    # Case 2: Files are identical — skip
    if src_hash == dst_hash:
        manifest[rel_key] = src_hash
        stats["skipped"] += 1
        return
    
    # Case 3: Files differ — strategy decides
    if strategy == "always_update":
        # Our authored files — safe to overwrite
        shutil.copy2(src, dst)
        manifest[rel_key] = src_hash
        stats["updated"] += 1
        print(f"  ~ {rel_key} (UPDATED)")
        
    elif strategy == "smart_merge":
        # Check if user modified the file since last sync
        if last_synced_hash is None:
            # Never synced before — we don't know if user edited it
            # Conservative: treat as user-edited, protect it
            stats["protected"] += 1
            print(f"  ! {rel_key} (differs — local protected, no prior sync record)")
        elif dst_hash == last_synced_hash:
            # Local file matches what we last synced — user hasn't edited it
            # Safe to update
            shutil.copy2(src, dst)
            manifest[rel_key] = src_hash
            stats["updated"] += 1
            print(f"  ~ {rel_key} (UPDATED — local was unmodified)")
        else:
            # User edited the file since last sync — protect their work
            stats["protected"] += 1
            print(f"  ! {rel_key} (PROTECTED — local has user edits)")

def sync_dir(src_dir, dst_dir, strategy="always_update", label=""):
    """Sync all files in a directory."""
    src_dir = Path(src_dir)
    if not src_dir.exists():
        return
    for f in sorted(src_dir.rglob("*")):
        if f.is_file():
            rel = f.relative_to(src_dir)
            rel_key = f"{label}/{rel}" if label else str(rel)
            sync_file(f, dst_dir / rel, rel_key, strategy)

# ============================================================
# SYNC: Scripts (SMART MERGE — protect local edits)
# ============================================================
print("Scripts:")
scripts_src = REPO / "scripts"
scripts_dst = CLAUDE / "scripts"
if scripts_src.exists():
    for f in sorted(scripts_src.iterdir()):
        if f.is_file():
            dst = scripts_dst / f.name
            sync_file(f, dst, f"scripts/{f.name}", "smart_merge")
            if dst.exists():
                dst.chmod(0o755)

# ============================================================
# SYNC: Commands (SMART MERGE — protect local edits)
# ============================================================
print("\nCommands:")
sync_dir(REPO / "commands", CLAUDE / "commands", "smart_merge", "commands")

# ============================================================
# SYNC: Agents (SMART MERGE — protect local edits)
# ============================================================
print("\nAgents:")
sync_dir(REPO / "agents", CLAUDE / "agents", "smart_merge", "agents")

# ============================================================
# SYNC: Rules (SMART MERGE — protect local edits)
# ============================================================
print("\nRules:")
sync_dir(REPO / "rules", CLAUDE / "rules", "smart_merge", "rules")

# ============================================================
# SYNC: Skills (SMART MERGE — protect user edits)
# ============================================================
print("\nSkills:")
skills_src = REPO / "skills"
if skills_src.exists():
    for cat_dir in sorted(skills_src.iterdir()):
        if not cat_dir.is_dir():
            continue
        for skill_dir in sorted(cat_dir.iterdir()):
            if not skill_dir.is_dir():
                continue
            local_skill = CLAUDE / "skills" / skill_dir.name
            for f in skill_dir.rglob("*"):
                if f.is_file():
                    rel = f.relative_to(skill_dir)
                    rel_key = f"skills/{skill_dir.name}/{rel}"
                    sync_file(f, local_skill / rel, rel_key, "smart_merge")

# ============================================================
# SYNC: Hooks script (SMART MERGE — protect local edits)
# ============================================================
print("\nHooks:")
hooks_src = REPO / "claude-hooks.sh"
hooks_dst = HOME / "bin" / "claude-hooks.sh"
if hooks_src.exists():
    sync_file(hooks_src, hooks_dst, "hooks/claude-hooks.sh", "smart_merge")
    if hooks_dst.exists():
        hooks_dst.chmod(0o755)

# ============================================================
# SYNC: Bin scripts (context-status.sh, etc.)
# ============================================================
print("\nBin scripts:")
bin_src = REPO / "bin"
bin_dst = HOME / "bin"
bin_dst.mkdir(parents=True, exist_ok=True)
if bin_src.exists() and bin_src.is_dir():
    for script in sorted(bin_src.iterdir()):
        if script.is_file() and script.name.startswith(("context-", "claude-")):
            dst = bin_dst / script.name
            sync_file(script, dst, f"bin/{script.name}", "smart_merge")
            if dst.exists():
                dst.chmod(0o755)

# ============================================================
# Templates — report only, never auto-apply
# ============================================================
print("\nTemplates:")
for tmpl in ["CLAUDE.md.template", "settings.json.template"]:
    tmpl_path = REPO / tmpl
    if tmpl_path.exists():
        print(f"  i {tmpl} available — review and manually apply if needed")

# Make all bin scripts executable
bin_dir = HOME / "bin"
if bin_dir.exists():
    for f in bin_dir.glob("*.sh"):
        f.chmod(0o755)

# Save updated manifest
MANIFEST_FILE.parent.mkdir(parents=True, exist_ok=True)
MANIFEST_FILE.write_text(json.dumps(manifest, indent=2, sort_keys=True))

# Summary
total = stats["added"] + stats["updated"] + stats["skipped"] + stats["protected"]
print(f"\n{'='*60}")
print(f"Sync Complete")
print(f"{'='*60}")
print(f"  Added:     {stats['added']}")
print(f"  Updated:   {stats['updated']}")
print(f"  Unchanged: {stats['skipped']}")
print(f"  Protected: {stats['protected']} (local edits preserved)")
print(f"  Total:     {total} files checked")
print(f"{'='*60}")

if stats["protected"] > 0:
    print(f"\n⚠️  {stats['protected']} skill file(s) have local edits and were NOT updated.")
    print("   To force-update a protected skill, delete it locally and re-run /sync-pull.")
SYNC_SCRIPT
```

### Step 3: Merge Insights-tagged sections from other machines into local CLAUDE.md

> Note: Full `##` section merge is already handled by `scripts/merge-claude-md.sh` in Step 1c.
> Step 3 only handles the finer-grained **Insights**-tagged section merge below.

#### Merge Insights sections from other machines into local CLAUDE.md
```bash
python3 << 'INSIGHTS_MERGE'
import re, socket
from pathlib import Path

HOME = Path.home()
REPO_INSIGHTS = Path("/tmp/antifragile-pull/assets/insights")

# Short hostname — skip our own insights file
raw_host = socket.gethostname()
short_host = raw_host.replace("Sumits-", "").replace(".local", "").replace(" ", "-")

if not REPO_INSIGHTS.exists():
    print("  No insights directory in repo — skipping")
else:
    # Collect all CLAUDE.md files to merge into
    claude_targets = []
    global_cmd = HOME / ".claude" / "CLAUDE.md"
    project_cmd = HOME / "CLAUDE.md"
    if project_cmd.exists():
        claude_targets.append(("project", project_cmd))
    elif global_cmd.exists():
        claude_targets.append(("global", global_cmd))

    if not claude_targets:
        print("  No CLAUDE.md found locally — skipping insights merge")
    else:
        total_merged = 0
        # Read insights from ALL machines (including our own — dedup handles it)
        for insights_file in sorted(REPO_INSIGHTS.glob("*.md")):
            source_machine = insights_file.stem
            content = insights_file.read_text(encoding="utf-8")

            # Extract individual sections (### or ## with Insights tag)
            pattern = r'(#{2,3}\s+[^\n]*\(Insights[^\)]*\)[^\n]*\n(?:(?!#{2,3}\s).*\n?)*)'
            sections = re.findall(pattern, content)

            if not sections:
                continue

            for label, target_path in claude_targets:
                target_content = target_path.read_text(encoding="utf-8")

                new_to_add = []
                for section in sections:
                    section = section.strip()
                    header_line = section.split("\n")[0].strip()
                    # Check if this exact header already exists in our CLAUDE.md
                    if header_line not in target_content:
                        new_to_add.append(section)

                if new_to_add:
                    with open(target_path, "a", encoding="utf-8") as f:
                        f.write(f"\n\n## Insights from {source_machine} (auto-merged via /sync-pull)\n")
                        for s in new_to_add:
                            f.write("\n" + s + "\n")
                    total_merged += len(new_to_add)
                    print(f"  + {len(new_to_add)} section(s) from {source_machine} → {label} CLAUDE.md")

        if total_merged == 0:
            print("  All insights already present locally — nothing to merge")
        else:
            print(f"\n  Total: {total_merged} Insights section(s) merged into local CLAUDE.md")
INSIGHTS_MERGE
```

### Step 4: Run security patch on all installed skills
```bash
if [ -f /tmp/antifragile-pull/assets/scripts/security-patch.sh ]; then
  echo ""
  bash /tmp/antifragile-pull/assets/scripts/security-patch.sh
fi
```

### Step 5: Install/update the skill security scanner
```bash
mkdir -p ~/.claude/scripts
if [ -f /tmp/antifragile-pull/assets/scripts/skill-security-scan.sh ]; then
  cp /tmp/antifragile-pull/assets/scripts/skill-security-scan.sh ~/.claude/scripts/skill-security-scan.sh
  chmod +x ~/.claude/scripts/skill-security-scan.sh
  echo "✅ Skill security scanner installed/updated"
fi
```

### Step 6: Show machine registry
```bash
echo ""
echo "=== Machine Registry ==="
if [ -d /tmp/antifragile-pull/assets/machines ]; then
  for mf in /tmp/antifragile-pull/assets/machines/*.json; do
    if [ -f "$mf" ]; then
      NAME=$(python3 -c "import json; d=json.load(open('$mf')); print(d.get('short_name','?'))")
      LAST=$(python3 -c "import json; d=json.load(open('$mf')); print(d.get('last_push','?'))")
      OS=$(python3 -c "import json; d=json.load(open('$mf')); print(d.get('os','?'))")
      echo "  Machine: $NAME | Last push: $LAST | OS: $OS"
    fi
  done
else
  echo "  No machine signatures found in repo yet"
fi
echo ""

# Show git log with machine tags (last 5 syncs)
echo "=== Recent Sync History ==="
cd /tmp/antifragile-pull && git log --oneline -5 --format="  %h %s" 2>/dev/null
echo ""
```

### Step 7: Verify counts
```bash
echo "Installed counts:"
echo "  Skills:   $(find ~/.claude/skills -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')"
echo "  Agents:   $(find ~/.claude/agents -type f 2>/dev/null | wc -l | tr -d ' ')"
echo "  Commands: $(find ~/.claude/commands -type f 2>/dev/null | wc -l | tr -d ' ')"
echo "  Rules:    $(find ~/.claude/rules -type f 2>/dev/null | wc -l | tr -d ' ')"
```

### Step 8: Clean up
```bash
rm -rf /tmp/antifragile-pull
```
