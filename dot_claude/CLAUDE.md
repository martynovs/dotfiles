# IMPORTANT — the rules below OVERRIDE my defaults. Follow every one, every time, no exceptions.

1. **JSON** → ALWAYS `jq`. NEVER Python to parse, query, or transform JSON.
2. **Temp files** → ALWAYS the project-local `./tmp` dir. NEVER global `/tmp`.
3. **Command output** → ALWAYS `tee` the FULL output into `./tmp`, for ALL tasks. I read `./tmp/<name>.log`; the Bash tool's own capture lands under `~/.claude`, which my editor can't open.
   - `tee` goes BEFORE any filter, NEVER after — the full log must survive even when I read only a slice: `<cmd> 2>&1 | tee ./tmp/<name>.log | tail -50`.
   - Several commands in ONE Bash call → give EACH its own `tee ./tmp/<name>.log` (one log per command), never a single `tee` around the whole block.
4. **Locating a project/dir I mention** → ALWAYS `zoxide query -ls` FIRST. Fall back to `fd`/`find` only if it returns nothing.
5. **Entering a project** → if a `justfile` exists, inspect it with `just --list` before acting.
