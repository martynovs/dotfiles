#!/bin/sh
# Open helpers for tmux, scoped to the current pane's directory.
#
# Usage:
#   open.sh tail <dir>        tail the clipboard's file path in a moor popup (if it is a file)
#   open.sh tail-pane <dir>   toggle a horizontal pane tailing the clipboard's file path
#   open.sh editor <dir>      open <dir> in VS Code and bring its window to the front

# Resolve the clipboard into an absolute path relative to <dir>; prints nothing if absent.
resolve_clip() {
  cd "$1" || return 0
  f=$(pbpaste | tr -d '\r\n' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  case "$f" in
    '~')   f=$HOME ;;
    '~/'*) f=$HOME/${f#\~/} ;;
    /*)    ;;                    # already absolute
    *)     f=$PWD/${f#./} ;;     # relative to the pane dir
  esac
  printf '%s' "$f"
}

case "$1" in
  tail)
    f=$(resolve_clip "$2")
    if [ -f "$f" ]; then
      tmux display-popup -E -w 90% -h 80% "moor -statusbar plain -follow \"$f\""
    else
      tmux display-message "Clipboard is not a file path: $f"
    fi
    ;;

  tail-pane)
    # Toggle a tracked horizontal pane that tails the clipboard's file path.
    # The pane id is remembered in the window-local @tail_pane option, so a
    # second press closes exactly this pane and not other panes you open.
    existing=$(tmux show-options -wqv @tail_pane)
    if [ -n "$existing" ] && tmux list-panes -F '#{pane_id}' | grep -qx "$existing"; then
      tmux kill-pane -t "$existing"
      tmux set-option -wu @tail_pane
      # Resume automatic window renaming now that the moor pane is gone.
      tmux set-option -wu automatic-rename
      exit 0
    fi
    f=$(resolve_clip "$2")
    if [ -f "$f" ]; then
      pane=$(tmux split-window -v -l 10 -d -c "$2" -P -F '#{pane_id}' "moor -statusbar plain -follow \"$f\"")
      tmux set-option -w @tail_pane "$pane"
      # Freeze the window name so focusing the moor pane doesn't rename it.
      # Splitting with -d kept the original pane active, so the name is still correct.
      tmux set-option -w automatic-rename off
    else
      tmux display-message "Clipboard is not a file path: $f"
    fi
    ;;

  editor)
    # If the focused Ghostty window is the quick terminal (a floating panel), dismiss
    # it first — otherwise VS Code activates behind the always-on-top quick terminal.
    sub=$(osascript -e 'tell application "System Events" to tell process "Ghostty" to get value of attribute "AXSubrole" of (value of attribute "AXFocusedWindow")' 2>/dev/null)
    if [ "$sub" = "AXFloatingWindow" ]; then
      osascript -e 'tell application "Ghostty" to perform action "toggle_quick_terminal" on terminal 1' >/dev/null 2>&1
    fi
    open -a "Visual Studio Code" "$2" >/dev/null 2>&1
    ;;
esac

exit 0
