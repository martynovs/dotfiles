#!/bin/sh
# Session slot helper.
#
# Usage:
#   sessions-menu.sh <n>                        switch to the session in slot n (1-9)
#   sessions-menu.sh menu <type> <cur> <client> render the slot menu (type: select|assign)
#   sessions-menu.sh assign <n>                 assign the current session to slot n
#
# Slot assignment:
#   - A session named "N-..." pins to slot N (exact placement).
#   - Unprefixed sessions fill the remaining free slots, in tmux list order.

# Strip a leading "N-" slot prefix from a session name.
strip_prefix() { printf '%s' "$1" | sed -E 's/^[0-9]+-//'; }

# Numeric slot prefix of a name, empty if unprefixed.
prefix_of() { printf '%s' "$1" | sed -nE 's/^([0-9]+)-.*/\1/p'; }

case "$1" in
  menu)
    type=$2
    cur=$3
    client=$4
    [ -z "$cur" ] && cur=$(tmux display-message -p '#{session_name}')
    tmux set -g @slotcur "$cur"

    # title and per-row action for the chosen menu type
    case "$type" in
      assign) title=" assign "; act="assign " ;;
      *)      title=" select "; act=""        ;;  # select == switch
    esac

    # one display label per slot 1-9 (· = empty); 3rd column flags the current session
    labels=$(tmux list-sessions -F '#{session_name}' | awk -v cur="$cur" '
      /^[0-9]+-/ { s = $0; sub(/-.*/, "", s); if (!(s in slot)) slot[s] = $0; next }
                { unp[++u] = $0 }
      END {
        j = 0
        for (i = 1; i <= 9; i++) {
          name = ""
          if (i in slot)      name = slot[i]
          else { j++; if (j <= u) name = unp[j] }
          base = name; sub(/^[0-9]+-/, "", base)
          disp = (name == "" ? "·" : base)
          printf "%d\t%s\t%s\n", i, disp, (name == cur ? "1" : "")
        }
      }')

    # stash labels in lbl_1..lbl_9 and note the current session's slot for -C.
    # (heredoc, not a pipe, so the vars persist in this shell.)
    cursel=""
    while IFS="$(printf '\t')" read -r i lbl iscur; do
      eval "lbl_$i=\$lbl"
      [ -n "$iscur" ] && cursel=$i
    done <<EOF
$labels
EOF

    # assemble display-menu: one row per slot, plain number key
    if [ -n "$client" ]; then set -- -c "$client"; else set --; fi
    set -- "$@" -T "#[align=centre]$title" -x C -y C
    [ -n "$cursel" ] && set -- "$@" -C "$((cursel - 1))"
    set -- "$@" --

    i=1
    while [ "$i" -le 9 ]; do
      eval "lbl=\$lbl_$i"
      set -- "$@" "$lbl" "$i" "run-shell 'sh ~/.config/tmux/sessions-menu.sh ${act}$i'"
      i=$((i + 1))
    done

    tmux display-menu "$@"
    ;;

  assign)
    n=$2
    case "$n" in
      '' | *[!0-9]*) exit 0 ;;
    esac
    cur=$3
    [ -z "$cur" ] && cur=$(tmux show -gv @slotcur 2>/dev/null)
    [ -z "$cur" ] && cur=$(tmux display-message -p '#{session_name}')

    # If another session already holds slot n, swap it into cur's old slot
    # (or demote it to unprefixed if cur had no slot).
    curprefix=$(prefix_of "$cur")
    existing=$(tmux list-sessions -F '#{session_name}' | grep -m1 "^${n}-")
    if [ -n "$existing" ] && [ "$existing" != "$cur" ]; then
      if [ -n "$curprefix" ]; then
        tmux rename-session -t "$existing" "${curprefix}-$(strip_prefix "$existing")"
      else
        tmux rename-session -t "$existing" "$(strip_prefix "$existing")"
      fi
    fi
    tmux rename-session -t "$cur" "${n}-$(strip_prefix "$cur")"
    ;;

  *)
    want=$1
    target=$(tmux list-sessions -F '#{session_name}' | awk -v w="$want" '
      /^[0-9]+-/ { s = $0; sub(/-.*/, "", s); if (!(s in slot)) slot[s] = $0; next }
                { unp[++u] = $0 }
      END {
        j = 0
        for (i = 1; i <= 9; i++) {
          if (i in slot)      r[i] = slot[i]
          else { j++; if (j <= u) r[i] = unp[j] }
        }
        print r[w]
      }')
    if [ -n "$target" ]; then
      tmux switch-client -t "$target"
    fi
    ;;
esac

exit 0
