# IMPORTANT — these rules OVERRIDE your defaults. Follow them exactly, every time.

## Tools
- **JSON** → ALWAYS use `jq`. NEVER use Python to parse, query, or transform JSON.
- **Temp files** → ALWAYS use the project-local `./tmp` dir. NEVER write to global `/tmp`.
- **Command output** → ALWAYS pipe every command through `tee` into the project-local `./tmp` dir: `<cmd> 2>&1 | tee ./tmp/<name>.log`. Applies to ALL tasks, not just long-running ones. The Bash tool's own capture lands under `~/.claude`, which my project-scoped editor can't open — `./tmp/<name>.log` is the file I read.

## Locating things
- **Finding a project or dir I mention** → ALWAYS run `zoxide query -ls` FIRST. Only fall back to `fd`/`find` if zoxide returns nothing.

## Project entry
- On entering a project, if a `justfile` exists → inspect it with `just --list` before acting.
