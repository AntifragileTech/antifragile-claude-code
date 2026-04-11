#!/bin/bash
# Claude Code Universal Hook Handler — All 17 Events
# Usage: claude-hooks.sh <event-name>
# Logs: ~/.claude/logs/hooks.log

LOG_DIR="$HOME/.claude/logs"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/hooks.log"

# Read hook input (stdin from Claude Code, fallback to TOOL_INPUT env var)
INPUT=$(cat 2>/dev/null)
[ -z "$INPUT" ] && INPUT="${TOOL_INPUT:-{}}"

# Helper: extract JSON field via python3
py() { printf '%s' "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); $1" 2>/dev/null || echo ""; }

# Helper: log to file
log() { printf '[%s] [%-8s] %s\n' "$(date +%H:%M:%S)" "$1" "$2" >> "$LOG"; }

case "${1:-}" in

  # ═══════════════════════════════════
  # SESSION LIFECYCLE
  # ═══════════════════════════════════

  session-start)
    log "START" "dir=$(pwd)"
    # Check OAuth token validity for MCP plugins
    if command -v claude >/dev/null 2>&1; then
      # Quick check: if claude-mem token file exists and is recent
      TOKEN_FILE="$HOME/.claude/plugins/claude-mem/token.json"
      if [ -f "$TOKEN_FILE" ]; then
        TOKEN_AGE=$(( ( $(date +%s) - $(stat -f%m "$TOKEN_FILE" 2>/dev/null || stat -c%Y "$TOKEN_FILE" 2>/dev/null || echo 0) ) / 60 ))
        if [ "$TOKEN_AGE" -gt 300 ]; then
          log "WARN" "OAuth token may be stale (${TOKEN_AGE}min old) — observer agents may fail"
          echo "WARNING: OAuth token is ${TOKEN_AGE}min old. Observer/memory agents may fail. Refresh token before spawning observers."
        fi
      fi
    fi
    # Detect project
    if [ -f package.json ]; then
      PKG=$(node -p "require('./package.json').name" 2>/dev/null || echo "")
      [ -n "$PKG" ] && echo "Project: $PKG"
    fi
    # Check for missing CLAUDE.md — flag for auto-generation
    CWD=$(pwd)
    if [ "$CWD" != "$HOME" ] && [ "$CWD" != "/" ]; then
      # Only check if we're in a project directory (has code files)
      HAS_CODE=$(ls package.json requirements.txt composer.json Cargo.toml go.mod *.py *.ts *.js 2>/dev/null | head -1)
      if [ -n "$HAS_CODE" ] && [ ! -f "CLAUDE.md" ]; then
        echo "--- NEW PROJECT DETECTED ---"
        echo "No CLAUDE.md found in $(pwd)"
        echo "AUTO-ACTION: Generate a project-level CLAUDE.md by scanning package.json, requirements.txt, .env*, README, and folder structure."
        echo "Include: project name, tech stack, key commands (dev/build/test/deploy), env var keys (NOT values), folder structure, external services."
        echo "--- END ---"
      fi
    fi
    # Ensure project memory directory exists
    PROJECT_DIR_KEY=$(pwd | sed 's|/|-|g')
    PROJECT_MEMORY="$HOME/.claude/projects/${PROJECT_DIR_KEY}/memory"
    mkdir -p "$PROJECT_MEMORY" 2>/dev/null
    # Auto-restore last session handoff (project-local first, global fallback)
    PROJECT_DIR_KEY=$(pwd | sed 's|/|-|g')
    PROJECT_HANDOFF="$HOME/.claude/projects/${PROJECT_DIR_KEY}/memory/handoff.md"
    GLOBAL_HANDOFF="$LOG_DIR/handoff.md"
    if [ -f "$PROJECT_HANDOFF" ]; then
      HANDOFF="$PROJECT_HANDOFF"
    else
      HANDOFF=""
    fi
    # Show project-local handoff if recent (< 48h)
    if [ -n "$HANDOFF" ] && [ -f "$HANDOFF" ]; then
      AGE=$(( ( $(date +%s) - $(stat -f%m "$HANDOFF" 2>/dev/null || stat -c%Y "$HANDOFF" 2>/dev/null || echo 0) ) / 3600 ))
      if [ "$AGE" -lt 48 ]; then
        echo "--- LAST SESSION HANDOFF (${AGE}h ago) ---"
        cat "$HANDOFF"
        echo "--- END HANDOFF ---"
      fi
    fi
    ;;

  session-end)
    REASON=$(py "print(d.get('reason','unknown'))")
    log "END" "reason=$REASON dir=$(pwd)"
    # Auto-save handoff state (project-local + global index)
    PROJECT_DIR_KEY=$(pwd | sed 's|/|-|g')
    PROJECT_MEMORY="$HOME/.claude/projects/${PROJECT_DIR_KEY}/memory"
    mkdir -p "$PROJECT_MEMORY" 2>/dev/null
    PROJECT_HANDOFF="$PROJECT_MEMORY/handoff.md"
    GLOBAL_HANDOFF="$LOG_DIR/handoff.md"
    # Write full handoff to project-local path
    {
      echo "# Session Handoff — $(date '+%Y-%m-%d %H:%M')"
      echo "## Directory: $(pwd)"
      if [ -f package.json ]; then
        echo "## Project: $(node -p 'require("./package.json").name' 2>/dev/null)"
      fi
      BRANCH=$(git branch --show-current 2>/dev/null)
      [ -n "$BRANCH" ] && echo "## Branch: $BRANCH"
      echo ""
      echo "## Recent changes"
      git log --oneline -5 2>/dev/null || echo "No git history"
      echo ""
      echo "## Modified files"
      git status --short 2>/dev/null || echo "No changes"
      echo ""
      echo "## Diff summary"
      git diff --stat 2>/dev/null | tail -10
    } > "$PROJECT_HANDOFF" 2>/dev/null
    # Append one row to global session index (NEVER overwrite)
    if [ ! -s "$GLOBAL_HANDOFF" ]; then
      echo "# Session Index" > "$GLOBAL_HANDOFF"
      echo "| Date | Time | Project | Directory | Status |" >> "$GLOBAL_HANDOFF"
      echo "|------|------|---------|-----------|--------|" >> "$GLOBAL_HANDOFF"
    fi
    PROJECT_NAME=$(basename "$(pwd)")
    echo "| $(date '+%d-%b-%Y') | $(date '+%H:%M') | $PROJECT_NAME | $(pwd) | done |" >> "$GLOBAL_HANDOFF"
    # Append to global NOTES.md (cross-project activity log, NEVER overwrite)
    GLOBAL_NOTES="$LOG_DIR/NOTES.md"
    echo "" >> "$GLOBAL_NOTES"
    echo "---" >> "$GLOBAL_NOTES"
    echo "## $(date '+%H:%M %d-%b-%Y') — $PROJECT_NAME ($(pwd))" >> "$GLOBAL_NOTES"
    echo "- Session ended (auto-logged by hook)" >> "$GLOBAL_NOTES"
    ;;

  pre-compact)
    TRIGGER=$(py "print(d.get('trigger','unknown'))")
    CUSTOM=$(py "print(d.get('custom_instructions',''))")
    SESSION_ID=$(py "print(d.get('session_id','unknown'))")
    TPATH=$(py "print(d.get('transcript_path',''))")
    log "COMPACT" "trigger=$TRIGGER session=$SESSION_ID dir=$(pwd)"
    # --- 1. Backup transcript before compaction ---
    BACKUP_DIR="$HOME/.claude/compact-backups"
    mkdir -p "$BACKUP_DIR"
    TS=$(date '+%Y%m%d-%H%M%S')
    if [ -n "$TPATH" ] && [ -f "$TPATH" ]; then
      TSIZE=$(( $(wc -c < "$TPATH" | tr -d ' ') / 1024 ))
      cp "$TPATH" "$BACKUP_DIR/${TS}-${TRIGGER}-${SESSION_ID:0:8}.jsonl"
      log "COMPACT" "transcript backed up (${TSIZE}KB)"
    fi
    # --- 2. Save rich context snapshot ---
    COMPACT_STATE="$BACKUP_DIR/${TS}-state.md"
    {
      echo "# Pre-Compact State — $(date '+%Y-%m-%d %H:%M:%S')"
      echo "**Trigger:** $TRIGGER"
      echo "**Session:** $SESSION_ID"
      echo "**Focus:** ${CUSTOM:-none}"
      [ -n "$TPATH" ] && echo "**Transcript:** ${TSIZE:-?}KB"
      echo ""
      echo "## Git State"
      echo "**Branch:** $(git branch --show-current 2>/dev/null || echo 'N/A')"
      echo "### Modified files:"
      echo '```'
      git status --short 2>/dev/null | head -20
      echo '```'
      echo "### Recent commits:"
      echo '```'
      git log --oneline -5 2>/dev/null
      echo '```'
      echo ""
      echo "## Working Directory"
      echo "**CWD:** $(pwd)"
      echo "**Project:** $(basename "$(pwd)")"
    } > "$COMPACT_STATE" 2>/dev/null
    # Also keep latest snapshot at fixed path for easy access
    cp "$COMPACT_STATE" "$LOG_DIR/pre-compact-state.md" 2>/dev/null
    # --- 3. Retention: keep only last 20 backups ---
    BCOUNT=$(ls -1 "$BACKUP_DIR"/*.jsonl 2>/dev/null | wc -l | tr -d ' ')
    if [ "$BCOUNT" -gt 20 ]; then
      ls -1t "$BACKUP_DIR"/*.jsonl | tail -n +21 | xargs rm -f 2>/dev/null
      ls -1t "$BACKUP_DIR"/*-state.md | tail -n +21 | xargs rm -f 2>/dev/null
      log "COMPACT" "pruned old backups (kept 20)"
    fi
    log "COMPACT" "pre-compact done: $COMPACT_STATE"
    ;;

  # ═══════════════════════════════════
  # USER PROMPT
  # ═══════════════════════════════════

  check-prompt)
    TPATH=$(py "print(d.get('transcript_path',''))")
    if [ -n "$TPATH" ] && [ -f "$TPATH" ]; then
      KB=$(( $(wc -c < "$TPATH" | tr -d ' ') / 1024 ))
      MSGS=$(py "print(d.get('message_count',0))")
      # Tier 1: Gentle reminder at 500KB
      if [ "$KB" -gt 500 ] && [ "$KB" -le 1000 ]; then
        echo "Context at ${KB}KB (~50% full). Finish current task, then run /auto-clear." >&2
      fi
      # Tier 2: Urgent at 1MB
      if [ "$KB" -gt 1000 ] && [ "$KB" -le 1500 ]; then
        echo "WARNING: Context at ${KB}KB (~75% full). Run /auto-clear NOW to save work and free context." >&2
      fi
      # Tier 3: Critical at 1.5MB — auto-compact will kick in soon
      if [ "$KB" -gt 1500 ]; then
        echo "CRITICAL: Context at ${KB}KB — auto-compact imminent. Run /auto-clear immediately or risk losing context quality." >&2
      fi
      # Track message count for task-switch detection
      if [ "$MSGS" -gt 0 ] && [ $(( MSGS % 15 )) -eq 0 ]; then
        echo "You're ${MSGS} messages in. If you've switched tasks, run /auto-clear to reset context." >&2
      fi
    fi
    ;;

  # ═══════════════════════════════════
  # PRE-TOOL — SAFETY GUARDS
  # ═══════════════════════════════════

  pre-bash)
    CMD=$(py "print(d.get('tool_input',{}).get('command',''))")
    # Block git add .env
    if echo "$CMD" | grep -qE 'git\s+add.*\.env'; then
      echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Cannot stage .env files — add to .gitignore instead"}}'
      exit 0
    fi
    # Block docker system prune
    if echo "$CMD" | grep -qE 'docker\s+system\s+prune'; then
      echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"docker system prune blocked — run manually if needed"}}'
      exit 0
    fi
    # Block prisma migrate reset
    if echo "$CMD" | grep -qE 'prisma\s+migrate\s+reset'; then
      echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"prisma migrate reset blocked — too destructive for automated use"}}'
      exit 0
    fi
    # Block force push to main/master
    if echo "$CMD" | grep -qE 'git\s+push.*(-f|--force)' && echo "$CMD" | grep -qE '\b(main|master)\b'; then
      echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Force push to main/master blocked — use regular push"}}'
      exit 0
    fi
    ;;

  pre-bash-build)
    CMD=$(py "print(d.get('tool_input',{}).get('command',''))")
    if echo "$CMD" | grep -qE 'git\s+commit'; then
      DIFF=$(git diff --cached --stat 2>/dev/null)
      [ -z "$DIFF" ] && exit 0
      for APP in $(echo "$DIFF" | grep -oE 'apps/(marketing|web|admin)' | sort -u); do
        PKG=$(cd "$APP" 2>/dev/null && node -p "require('./package.json').name" 2>/dev/null)
        [ -n "$PKG" ] && npx turbo build --filter="$PKG" 2>&1 | tail -5
      done
    fi
    ;;

  pre-write)
    LINES=$(py "print(d.get('tool_input',{}).get('content','').count(chr(10))+1)")
    [ -z "$LINES" ] && LINES=0
    if [ "$LINES" -gt 300 ]; then
      echo "WARNING: Writing $LINES lines. Consider splitting into smaller files (300 line limit)." >&2
    fi
    ;;

  # ═══════════════════════════════════
  # POST-TOOL — VALIDATION
  # ═══════════════════════════════════

  post-ts)
    FILE=$(py "print(d.get('tool_input',{}).get('file_path',''))")
    if [ -n "$FILE" ] && echo "$FILE" | grep -qE '\.(ts|tsx)$'; then
      cd "$(dirname "$FILE")" 2>/dev/null && npx tsc --noEmit --pretty 2>&1 | head -15
    fi
    ;;

  post-lint)
    FILE=$(py "print(d.get('tool_input',{}).get('file_path',''))")
    if [ -n "$FILE" ] && echo "$FILE" | grep -qE '\.(js|jsx|ts|tsx)$'; then
      npx eslint --no-error-on-unmatched-pattern --max-warnings=0 "$FILE" 2>&1 | tail -10
    fi
    ;;

  post-prisma)
    FILE=$(py "print(d.get('tool_input',{}).get('file_path',''))")
    if [ -n "$FILE" ] && echo "$FILE" | grep -qE 'schema\.prisma$'; then
      cd "$(dirname "$FILE")" 2>/dev/null && npx prisma validate 2>&1 | head -10
    fi
    ;;

  # ═══════════════════════════════════
  # FAILURE LOGGING
  # ═══════════════════════════════════

  log-failure)
    TOOL=$(py "print(d.get('tool_name','?'))")
    ERR=$(py "print(str(d.get('error',''))[:200])")
    log "FAIL" "$TOOL: $ERR"
    ;;

  # ═══════════════════════════════════
  # NOTIFICATIONS
  # ═══════════════════════════════════

  log-notify)
    MSG=$(py "print(str(d.get('message',''))[:200])")
    TYPE=$(py "print(d.get('notification_type','?'))")
    log "NOTIFY" "[$TYPE] $MSG"
    ;;

  # ═══════════════════════════════════
  # PERMISSIONS
  # ═══════════════════════════════════

  log-perm)
    TOOL=$(py "print(d.get('tool_name','?'))")
    log "PERM" "tool=$TOOL"
    ;;

  # ═══════════════════════════════════
  # SUBAGENTS
  # ═══════════════════════════════════

  subagent-start)
    TYPE=$(py "print(d.get('agent_type','?'))")
    log "AGENT+" "$TYPE"
    ;;

  subagent-stop)
    TYPE=$(py "print(d.get('agent_type','?'))")
    log "AGENT-" "$TYPE"
    ;;

  # ═══════════════════════════════════
  # COMPLETION
  # ═══════════════════════════════════

  check-stop)
    ACTIVE=$(py "print(d.get('stop_hook_active',False))")
    [ "$ACTIVE" = "True" ] && exit 0
    log "STOP" "dir=$(pwd)"

    # Auto-check uncommitted work (only if in a git repo)
    DIRTY=0
    IS_GIT=$(git rev-parse --is-inside-work-tree 2>/dev/null)
    if [ "$IS_GIT" = "true" ]; then
      DIRTY=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
    fi

    # Auto-check context size
    TPATH=$(py "print(d.get('transcript_path',''))")
    KB=0
    if [ -n "$TPATH" ] && [ -f "$TPATH" ]; then
      KB=$(( $(wc -c < "$TPATH" | tr -d ' ') / 1024 ))
    fi

    # Build smart reminder
    REMINDERS=""
    if [ "$IS_GIT" = "true" ] && [ "$DIRTY" -gt 0 ]; then
      REMINDERS="${REMINDERS}$DIRTY uncommitted files — commit or stash before /clear. "
    fi
    if [ "$KB" -gt 500 ]; then
      REMINDERS="${REMINDERS}Context is ${KB}KB — run /auto-clear to save work and reset. "
    fi

    if [ -n "$REMINDERS" ]; then
      echo "{\"additionalContext\":\"Auto-check: ${REMINDERS}\"}"
    fi
    ;;

  task-complete)
    log "TASK-OK" "dir=$(pwd)"
    ;;

  # ═══════════════════════════════════
  # AGENT TEAMS
  # ═══════════════════════════════════

  teammate-idle)
    NAME=$(py "print(d.get('teammate_name','?'))")
    log "IDLE" "name=$NAME"
    ;;

  # ═══════════════════════════════════
  # CONFIG CHANGES
  # ═══════════════════════════════════

  config-change)
    SRC=$(py "print(d.get('source','?'))")
    log "CONFIG" "source=$SRC"
    echo "Config changed: $SRC" >&2
    ;;

  # ═══════════════════════════════════
  # WORKTREE
  # ═══════════════════════════════════

  worktree-remove)
    WPATH=$(py "print(d.get('worktree_path','?'))")
    log "WTREE-" "path=$WPATH"
    ;;

  *)
    log "?" "Unknown event: ${1:-empty}"
    ;;

esac

exit 0
