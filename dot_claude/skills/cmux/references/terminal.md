# cmux Terminal & Pane Reference

## Identity & Discovery

```bash
cmux identify                          # who am I? current workspace + surface
cmux list-windows                      # all windows
cmux list-workspaces                   # workspaces in current window
cmux list-panes [--workspace <id>]     # panes in workspace
cmux list-pane-surfaces --pane <id>    # surfaces (tabs) within a pane
cmux current-window
cmux current-workspace
```

## Windows & Workspaces

```bash
cmux new-window
cmux focus-window --window <id>
cmux close-window --window <id>

cmux new-workspace [--cwd <path>] [--command <cmd>]   # new workspace, optionally with dir/command
cmux select-workspace --workspace <id>
cmux rename-workspace [--workspace <id>] <title>
cmux close-workspace --workspace <id>
```

## Panes & Splits

```bash
# Split the current surface
cmux new-split <left|right|up|down> [--workspace <id>] [--surface <id>]

# Create a new pane (terminal or browser)
cmux new-pane [--type terminal|browser] [--direction left|right|up|down] [--url <url>]

# Focus a pane
cmux focus-pane --pane <id> [--workspace <id>]
```

## Surfaces (Tabs)

Surfaces are tabs within a pane. Each pane can have multiple surfaces.

```bash
cmux new-surface [--type terminal|browser] [--pane <id>] [--url <url>]
cmux close-surface [--surface <id>]
cmux move-surface --surface <id> [--pane <id>] [--workspace <id>] [--window <id>] [--before <id>] [--after <id>] [--index <n>] [--focus <true|false>]
cmux reorder-surface --surface <id> (--index <n> | --before <id> | --after <id>)
cmux rename-tab [--workspace <id>] [--surface <id>] <title>
cmux drag-surface-to-split --surface <id> <left|right|up|down>
```

## Sending Input to Terminals

```bash
# Send text (appended to current input, no newline)
cmux send [--workspace <id>] [--surface <id>] <text>

# Send text + execute (add \n for Enter)
cmux send --surface <id> "ls -la\n"

# Send a named key
cmux send-key [--workspace <id>] [--surface <id>] <key>
# Keys: Enter, Escape, Tab, Up, Down, Left, Right, C-c, C-d, C-z, etc.

# Send to a panel (sidebar panel)
cmux send-panel --panel <id> <text>
cmux send-key-panel --panel <id> <key>
```

## Reading Screen Output

```bash
cmux read-screen [--workspace <id>] [--surface <id>] [--scrollback] [--lines <n>]
# Returns visible terminal content. Use --scrollback for history.
# --lines limits how many lines to return.
```

## Sidebar Status & Progress

Use these to surface metadata and progress in the cmux sidebar — great for long-running tasks.

```bash
# Status key-value items (shown in sidebar)
cmux set-status <key> <value> [--icon <name>] [--color <#hex>]
cmux clear-status <key>
cmux list-status

# Progress bar (0.0–1.0)
cmux set-progress 0.5 [--label "Processing files..."]
cmux clear-progress

# Structured log entries
cmux log [--level info|warn|error] [--source <name>] -- <message>
cmux list-log [--limit <n>]
cmux clear-log

# Sidebar visibility
cmux sidebar-state
```

**Key facts:**
- `set-progress` takes a **float 0.0–1.0**, not a percentage integer — `0.2` not `20`
- `--label` on `set-progress` is optional but strongly recommended; it's what the user reads while waiting
- `--icon` on `set-status` uses **SF Symbols** names (e.g. `magnifyingglass`, `checkmark.circle`, `xmark.circle`, `arrow.triangle.2.circlepath`, `circle`, `clock`) — omit if unsure
- `--color` takes a hex value like `#4A90E2` (blue), `#27AE60` (green), `#E74C3C` (red)
- Good lifecycle convention for a batch task: `"starting"` → `"processing"` → `"complete"` (or `"failed"`)

## Notifications

```bash
cmux notify --title <text> [--subtitle <text>] [--body <text>]
cmux list-notifications
cmux clear-notifications
```

## ID Format

Commands accept IDs as:
- **Refs** (default): `window:1`, `workspace:2`, `pane:3`, `surface:4`, `tab:5`
- **UUIDs**: full UUID strings
- **Indexes**: plain integers (position-based)

Pass `--id-format uuids` or `--id-format both` to include UUIDs in output.

## Other Useful Commands

```bash
cmux tree [--all] [--workspace <id>]          # show workspace/pane/surface tree
cmux tab-action --action <name> [--tab <id>] [--title <text>] [--url <url>]
cmux workspace-action --action <name> [--workspace <id>] [--title <text>]
cmux surface-health [--workspace <id>]        # check surface health
cmux markdown open <path>                     # open markdown in formatted viewer panel
```

## Tips

- Use `--json` on any command for machine-readable output
- `CMUX_WORKSPACE_ID` / `CMUX_SURFACE_ID` are pre-set — omit `--workspace`/`--surface` to target the current context
- `cmux ping` verifies the socket is alive
- `cmux capabilities` lists what the running app supports

## Common Workflows

**Run a command in a new split and watch it:**
```bash
# Open a right split
cmux new-split right
# Identify the new surface (focus shifts to new pane after split)
cmux identify
# Send a command — \n is required to execute it (simulates Enter)
cmux send --surface <new-surface-id> "npm run build\n"
# Read its output — use --scrollback to capture logs that scrolled past the visible area
cmux read-screen --surface <new-surface-id> --scrollback
# Poll again if the process is still starting up
cmux read-screen --surface <new-surface-id> --scrollback --lines 50
```

**Report task progress to sidebar:**
```bash
cmux set-status "task" "Analyzing files" --icon "magnifyingglass" --color "#4A90E2"
cmux set-progress 0.0 --label "Starting..."
# ... do work ...
cmux set-progress 0.5 --label "Halfway there"
# ... finish ...
cmux set-progress 1.0 --label "Done"
cmux clear-progress
cmux set-status "task" "Complete" --icon "checkmark.circle" --color "#27AE60"
```

**Navigate to a specific workspace:**
```bash
cmux list-workspaces
cmux select-workspace --workspace workspace:2
```
