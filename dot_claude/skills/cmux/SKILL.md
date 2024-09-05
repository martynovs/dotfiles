---
name: cmux
description: Use this skill whenever you need to actually operate the cmux terminal multiplexer — not just explain it, but DO things with it. Always read this skill before: opening a new split or terminal pane; running any long-running command (tests, builds, npm install, servers, migrations — these always go in a new split so the user can watch); renaming, navigating, or creating workspaces; reading what's on screen in another pane or surface; sending ctrl-c or keystrokes to kill a hung process; opening a browser pane to show the user a URL; showing progress in the cmux sidebar. If the user asks you to run something and you're inside cmux (check $CMUX_WORKSPACE_ID), this skill applies — even if they don't say "cmux" or "pane" explicitly. Don't use for pure explanations or outside a cmux session.
---

# cmux — Terminal Multiplexer Control

`cmux` communicates with the running cmux app via a Unix socket. All commands run instantly — no need to wait for shell spawning.

**Read the relevant reference when you need command syntax:**
- `references/terminal.md` — panes, splits, surfaces, sending input, reading output, sidebar/progress, notifications
- `references/browser.md` — all `cmux browser` subcommands (open, navigate, click, snapshot, tabs, etc.)

## When to use cmux (two questions to ask first)

**1. Am I running inside cmux?**
Check `$CMUX_WORKSPACE_ID` — it's auto-set in cmux terminals. If it's empty or unset, don't use cmux.

**2. Does the user want to *see* the content, or do they just want an answer?**
If inside cmux, use cmux capabilities by default for anything the user wants to view or interact with — even if they don't explicitly say "open a pane" or "use cmux". The user knows you're running inside cmux and expects you to use its abilities naturally.

The key question is intent, not phrasing:
- "look up the React docs for me" → user wants to see the page → open a browser pane
- "explain how useEffect cleanup works" → user wants an answer → `WebFetch` internally, no pane
- "check the nginx logs on staging" → user wants to see/watch → open a terminal split
- "how many 500 errors in today's nginx log" → user wants a number → `ssh` + grep internally, no pane

**Long-running processes always go in a new pane.** If a command will take more than a few seconds (tests, builds, installs, servers, migrations, compilers), run it in a split rather than the current surface — even if the user didn't ask for that explicitly. This lets them watch progress, spot hangs, and keep interacting with you in the current pane while the process runs. Quick one-shot commands (`ls`, `which`, `echo`, `cat`) can run inline.

If in doubt and inside cmux: prefer showing content in a pane over answering from memory.
