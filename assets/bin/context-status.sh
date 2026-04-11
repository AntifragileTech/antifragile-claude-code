#!/bin/bash
# Created: 19:43 11-Apr-2026
# Context status for Claude Code statusLine
# Shows: ~120K/1M (12%)

TDIR="$HOME/.claude/projects"

# Find the most recently modified transcript
TP=$(ls -t "$TDIR"/*/*.jsonl "$TDIR"/*.jsonl 2>/dev/null | head -1)

if [ -z "$TP" ] || [ ! -f "$TP" ]; then
  echo "ctx:?"
  exit 0
fi

BYTES=$(wc -c < "$TP" 2>/dev/null | tr -d ' ')

# Conversation tokens from transcript (~4 bytes per token)
CONV_K=$(( BYTES / 4 / 1000 ))

# Fixed overhead: system prompt + MCP tools + skills + memory + agents
# Based on /context readout: ~75K tokens of fixed overhead
OVERHEAD_K=75

TOTAL_K=$(( CONV_K + OVERHEAD_K ))
MAX_K=1000
PCT=$(( TOTAL_K * 100 / MAX_K ))
[ "$PCT" -gt 100 ] && PCT=100

echo "~${TOTAL_K}K/1M (${PCT}%)"
