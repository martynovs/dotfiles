#!/bin/sh
# Claude focus-window helpers for tmux.
#
# A companion tool sets @claude-focus-window to "<session>:<window>" (and
# @claude-status to a status-bar marker) when a Claude window wants attention;
# its window name gets a trailing " •" bullet. These handlers consume that state.
#
# Usage:
#   claude.sh switch-focus                      jump to the focus window, clear its marks
#   claude.sh show-buffer                       fzf over the 'claude' buffer, switch to a pick
#   claude.sh clear-focus <sess> <idx> <name>   strip the bullet; clear focus state if it's the one

case "$1" in
  switch-focus)
    w=$(tmux show -gv @claude-focus-window 2>/dev/null)
    [ -z "$w" ] && exit 0
    n=$(tmux display-message -p -t "$w" '#{window_name}')
    tmux rename-window -t "$w" "${n% •}"
    tmux switch-client -t "$w"
    tmux set -g @claude-status ''
    tmux set -g @claude-focus-window ''
    ;;

  show-buffer)
    tmux show-buffer -b claude | tac | \
      fzf --reverse \
          --footer 'enter:switch, ctrl-d:clear' \
          --bind 'ctrl-d:execute(tmux delete-buffer -b claude)+abort' \
          --bind '§:abort' | \
      cut -d'[' -f3 | cut -d']' -f1 | \
      xargs -I{} tmux switch-client -t {}
    ;;

  clear-focus)
    sess=$2
    idx=$3
    name=$4
    # strip a trailing " •" bullet from the window's name
    case "$name" in
      *' •') tmux rename-window -t "$sess:$idx" "${name% •}" ;;
    esac
    # if this window was the focus target, clear the focus state
    if [ "$sess:$idx" = "$(tmux show -gv @claude-focus-window 2>/dev/null)" ]; then
      tmux set -g @claude-focus-window ''
      tmux set -g @claude-status ''
    fi
    ;;
esac

exit 0
