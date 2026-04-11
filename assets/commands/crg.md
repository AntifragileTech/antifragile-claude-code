---
description: "Code Review Graph — build, register, and manage knowledge graphs for your codebase. Reduces token usage by 6-49× on reviews and coding tasks."
argument-hint: "build | register | status | search <query> | update | visualize"
allowed-tools: Bash, Read, Write, Edit, Glob
---

# /crg — Code Review Graph Manager

Manages the code-review-graph knowledge graph for the current project. The graph maps your codebase structure (functions, classes, imports, calls, tests) into a local SQLite database so Claude reads only what matters — drastically reducing token usage.

## Prerequisites

- `code-review-graph` must be installed: `uv tool install code-review-graph`
- PATH must include `~/.local/bin`

## Commands

Parse `$ARGUMENTS` to determine the subcommand. Default to `build` if no argument given.

### `build` (default)

Full setup: install MCP + hooks, build the graph, register in global registry.

```bash
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"

# Get project root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
PROJECT_NAME=$(basename "$REPO_ROOT")

echo "🔨 Building code-review-graph for: $PROJECT_NAME"
echo "   Path: $REPO_ROOT"

# Step 1: Install MCP server + hooks for Claude Code
cd "$REPO_ROOT"
code-review-graph install --repo "$REPO_ROOT"

# Step 2: Build the graph
code-review-graph build --repo "$REPO_ROOT"

# Step 3: Register in global registry
code-review-graph register "$REPO_ROOT" --alias "$PROJECT_NAME" 2>/dev/null || true

echo ""
echo "✅ Graph built and registered as '$PROJECT_NAME'"
echo "   Database: $REPO_ROOT/.code-review-graph/graph.db"
echo "   MCP tools are now available in this project"
```

After build, report:
- Number of nodes (functions, classes) parsed
- Number of edges (calls, imports, tests) mapped
- Languages detected
- Database file size

### `register`

Register the current project in the global multi-repo registry (without rebuilding).

```bash
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
PROJECT_NAME=$(basename "$REPO_ROOT")
code-review-graph register "$REPO_ROOT" --alias "$PROJECT_NAME"
echo "✅ Registered: $PROJECT_NAME → $REPO_ROOT"
```

### `status`

Show graph status for the current project + list all registered repos.

```bash
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
DB_PATH="$REPO_ROOT/.code-review-graph/graph.db"

echo "📊 Code Review Graph Status"
echo "   Project: $(basename "$REPO_ROOT")"

if [ -f "$DB_PATH" ]; then
  SIZE=$(du -h "$DB_PATH" | cut -f1)
  echo "   Database: $DB_PATH ($SIZE)"
  echo "   Status: ✅ Graph exists"
else
  echo "   Status: ❌ No graph — run /crg build"
fi

echo ""
echo "📋 All registered repos:"
code-review-graph repos
```

### `update`

Incremental update — re-parse only changed files since last build.

```bash
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
code-review-graph update --repo "$REPO_ROOT"
echo "✅ Graph updated incrementally"
```

### `search <query>`

Search across all registered repos for functions, classes, or patterns.

```bash
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"
# Use the MCP tool cross_repo_search if available, otherwise CLI
code-review-graph search "$QUERY"
```

### `visualize`

Generate an interactive D3.js visualization of the current project's graph.

```bash
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
code-review-graph visualize --repo "$REPO_ROOT"
echo "🌐 Visualization generated — open the HTML file in your browser"
```

## After Build

Once the graph is built, Claude Code automatically gets 22 MCP tools including:
- `detect_changes` — risk-scored change analysis
- `get_impact_radius` — blast radius of any change
- `get_review_context` — token-efficient code snippets for review
- `semantic_search_nodes` — find functions/classes by keyword
- `query_graph` — trace callers, callees, imports, tests
- `get_architecture_overview` — high-level codebase structure

These tools are **preferred over Grep/Glob/Read** for codebase exploration — they're faster and use fewer tokens.

## Notes

- Graph is stored at `.code-review-graph/graph.db` in the project root
- Add `.code-review-graph/` to `.gitignore` (it's a local cache, not source code)
- The graph auto-updates via hooks when you edit files in Claude Code
- Global registry lives at `~/.code-review-graph/registry.json`
