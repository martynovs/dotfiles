#!/bin/sh
# just recipe menu helper.
#
# Usage:
#   just-menu.sh menu <path> <client>     render a menu of recipes from the justfile near <path>
#   just-menu.sh run  <path> <recipe>     run a recipe in a new split (prompts for args if it takes any)
#
# Recipes are read with `just --dump --dump-format json`, so file order and docs
# are preserved. Private recipes are hidden. Recipes that take parameters open a
# command-prompt for their arguments before running. The chosen recipe runs as
# keystrokes in a fresh interactive shell in a horizontal split, so the pane and
# its output stay around afterwards.
#
# Modules (`mod foo 'sub/justfile'`) are walked recursively: their recipes show
# up as `foo::recipe` (and `foo::bar::recipe` for nested modules), grouped under
# a separator line, and run with `just foo::recipe` from the root justfile's dir.

SELF="sh ~/.config/tmux/just-menu.sh"
SEP=$(printf '\037')   # US: a non-whitespace field separator, so empty fields survive `read`

# Pull the recipe list, one per line: name <US> args <US> doc (file order, no private).
# `name` is qualified with the module path for module recipes, e.g. `ng::build`.
# `args` is the recipe's parameter signature, e.g. `env tag="latest"`, `+files`, `*flags`.
# A non-whitespace separator (passed as $sep) is used so empty args/doc fields
# don't collapse on read. `walk` recurses into `.modules`, prefixing each level.
recipes_tsv() {
  cd "$1" 2>/dev/null || return 1
  just --dump --dump-format json 2>/dev/null | jq -r --arg sep "$SEP" '
    def params:
      ((.parameters // [])
        | map((if .kind == "plus" then "+" elif .kind == "star" then "*" else "" end)
              + .name
              + (if .default != null then "=\"" + (.default | tostring) + "\"" else "" end))
        | join(" "));
    def walk($prefix):
      ( (.recipes // {})
        | to_entries
        | map(select((.value.private // false) | not))
        | .[]
        | [ ($prefix + .key), (.value | params), (.value.doc // "") ]
        | join($sep) ),
      ( (.modules // {})
        | to_entries
        | .[]
        | .key as $m
        | (.value | walk($prefix + $m + "::")) );
    walk("")'
}

case "$1" in
  menu)
    path=$2
    client=$3
    [ -z "$path" ] && path=$(tmux display-message -p '#{pane_current_path}')

    rows=$(recipes_tsv "$path")
    if [ -z "$rows" ]; then
      tmux display-message ' no justfile here '
      exit 0
    fi

    # one mnemonic key per recipe: 1-9 then a-z minus q (q quits the menu;
    # empty once we run out)
    keys=123456789abcdefghijklmnoprstuvwxyz
    maxdoc=80   # truncate long docs so one recipe can't blow out the menu width

    # pass 1: widest recipe name, so the description column lines up
    w=0
    while IFS="$SEP" read -r name args doc; do
      [ ${#name} -gt "$w" ] && w=${#name}
    done <<EOF
$rows
EOF

    if [ -n "$client" ]; then set -- -c "$client"; else set --; fi
    set -- "$@" -T '#[align=centre] just ' -x C -y C --

    # pass 2: build one row per recipe.
    # layout: <name padded to w>  <args signature>  <dimmed doc>
    # args is the recipe's parameter signature (you'll be prompted for them on run).
    # A separator line is inserted whenever the module prefix changes, so each
    # module's recipes read as their own group.
    i=0
    lastmod=
    while IFS="$SEP" read -r name args doc; do
      [ -z "$name" ] && continue
      # module prefix = everything up to the last "::" (empty for top-level recipes)
      case "$name" in
        *::*) mod=${name%::*}:: ;;
        *)    mod= ;;
      esac
      if [ "$mod" != "$lastmod" ]; then
        set -- "$@" ""
        lastmod=$mod
      fi
      i=$((i + 1))
      key=$(printf '%s' "$keys" | cut -c "$i")
      if [ "${#doc}" -gt "$maxdoc" ]; then
        doc="$(printf '%s' "$doc" | cut -c "1-$((maxdoc - 1))")…"
      fi
      desc="$args"
      if [ -n "$doc" ]; then
        # single space between args and doc — they're already set apart by colour
        [ -n "$desc" ] && desc="$desc "
        desc="$desc#[dim]$doc"
      fi
      if [ -n "$desc" ]; then
        label=$(printf "%-${w}s  %s" "$name" "$desc")
      else
        label="$name"
      fi
      set -- "$@" "$label" "$key" "run-shell '$SELF run \"$path\" \"$name\"'"
    done <<EOF
$rows
EOF

    tmux display-menu "$@"
    ;;

  run)
    path=$2
    recipe=$3
    if [ "$#" -lt 4 ]; then
      # first invocation: if the recipe takes args, prompt for them (showing the
      # signature), then re-enter with what was typed
      sig=$(recipes_tsv "$path" | awk -F"$SEP" -v r="$recipe" '$1 == r { print $2 }')
      if [ -n "$sig" ]; then
        tmux command-prompt -p "just $recipe $sig:" \
          "run-shell '$SELF run \"$path\" \"$recipe\" \"%%\"'"
        exit 0
      fi
      args=""
    else
      args=$4
    fi
    # Open a horizontal split in the recipe's dir running the interactive shell,
    # then type the command into it once the shell is up. Running it as keystrokes
    # (rather than the pane's command) keeps the shell loaded and the pane open
    # afterwards, so output stays and you can re-run or scroll. Module recipes use
    # `just foo::recipe`, which just resolves from the root justfile's dir ($path).
    cmd="just $recipe"
    [ -n "$args" ] && cmd="$cmd $args"
    pane=$(tmux split-window -v -l 30% -c "$path" -P -F '#{pane_id}')
    tmux send-keys -t "$pane" "$cmd" Enter
    ;;
esac

exit 0
