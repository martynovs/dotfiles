#!/usr/bin/env bash
input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')

# If the session dir has a justfile, surface its recipes as context so the
# available `just` commands are known up front (see global CLAUDE.md rule).
# Collection mirrors ~/.config/tmux/just-menu.sh: `just --dump --dump-format
# json` preserves file order, modules become `mod::recipe`, private recipes are
# dropped, and each recipe keeps its parameter signature and doc comment.
if [ -n "$cwd" ] && command -v just >/dev/null 2>&1 && cd "$cwd" 2>/dev/null; then
  dump=$(just --dump --dump-format json 2>/dev/null) || dump=
  if [ -n "$dump" ]; then
    recipes=$(printf '%s' "$dump" | jq -r '
      def params:
        ((.parameters // [])
          | map((if .kind == "plus" then "+" elif .kind == "star" then "*" else "" end)
                + .name
                + (if .default != null then "=\"" + (.default | tostring) + "\"" else "" end))
          | join(" "));
      def walk($p):
        ( (.recipes // {})
          | to_entries
          | map(select((.value.private // false) | not))
          | .[]
          | ($p + .key)
            + (if (.value | params) != "" then " " + (.value | params) else "" end)
            + (if (.value.doc // "") != "" then "  # " + .value.doc else "" end) ),
        ( (.modules // {})
          | to_entries | .[] | .key as $m | (.value | walk($p + $m + "::")) );
      walk("")')
    if [ -n "$recipes" ]; then
      # shellcheck disable=SC2016  # literal backticks/<recipe> are intentional prose
      printf 'Available `just` recipes in this project (run with `just <recipe>`):\n%s\n' "$recipes"
    fi
  fi
fi
