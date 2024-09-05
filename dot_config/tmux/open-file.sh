#!/bin/sh
# File-sidebar helper for tmux: an nnn pane that opens picks in the editor pane it
# was launched from. Two roles, both run this same script:
#
#   open-file.sh sidebar <pane_id> <dir>   spawn an nnn sidebar next to the editor
#                                          pane (bound to a tmux key). Injects
#                                          NNN_OPENER (back to this script) and
#                                          TARGET_PANE (the explicit target id).
#   open-file.sh <file>                    opener invoked by `nnn -c` for the
#                                          picked file, via the NNN_OPENER above.
#
# Terminal editors have no remote-control socket, so "open" = tmux types the
# editor's own open command into TARGET_PANE (the pane id captured at launch — no
# `{right-of}` direction guessing). The exact keystrokes vary per app, so the
# opener dispatches on the target pane's running command; add cases as needed.

# this script's own absolute path, resolved regardless of how it was invoked
# (nnn needs an absolute NNN_OPENER)
self="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

# Colors for the sidebar, scoped to it via the -e injection below. We use ANSI
# slot indices (00-0F) rather than 256-color codes, so nnn inherits the terminal's
# own palette. nnn's community OneDark theme (jarun/nnn wiki: Themes), with EXE on
# the dark magenta slot (05) so executables read reddish-magenta.
# NNN_FCOLORS field order (see `man nnn` ENVIRONMENT):
#   blk  chr  DIR  EXE  reg  hard SYM  miss orph fifo sock unk
#   blue blue blue mag  dflt dflt cyan dflt red  whit whit grn
fcolors='0404040500000600010F0F02'
colors='#04060502'                   # tab colors: blue cyan magenta green

case "$1" in
  sidebar)
    # $2 = editor pane id, $3 = its working dir. Toggle on an explicit pane marker
    # (@file_sidebar) rather than pane_current_command — nnn runs under the shell,
    # so the process name reads as "fish", not "nnn".
    sb_pane=$(tmux list-panes -t "$2" -F '#{pane_id} #{@file_sidebar}' \
      | awk '$2 == "1" { print $1; exit }')
    if [ -n "$sb_pane" ]; then
      tmux kill-pane -t "$sb_pane"
    else
      # `-hb` puts nnn on the left; `-c` cli-opener mode is mandatory or nnn
      # forks $EDITOR into its own pane instead of calling us back.
      new_pane=$(tmux split-window -hb -l 25 -t "$2" -c "$3" \
        -e "NNN_OPENER=$self" -e "TARGET_PANE=$2" \
        -e "NNN_FCOLORS=$fcolors" -e "NNN_COLORS=$colors" \
        -P -F '#{pane_id}' 'nnn -c')
      tmux set-option -p -t "$new_pane" @file_sidebar 1
    fi
    ;;
  *)
    # opener: $1 = file path from `nnn -c` (directories don't fire the opener).
    # $TARGET_PANE was injected into this pane's env when the sidebar launched.
    [ -f "$1" ] || exit 0
    [ -n "$TARGET_PANE" ] || exit 0

    # Pick the open keystrokes for whatever app is running in the target pane.
    app=$(tmux display-message -p -t "$TARGET_PANE" '#{pane_current_command}')
    case "$app" in
      hx)         tmux send-keys -t "$TARGET_PANE" Escape; tmux send-keys -t "$TARGET_PANE" ":open $1" Enter ;;
      nvim|vim)   tmux send-keys -t "$TARGET_PANE" Escape; tmux send-keys -t "$TARGET_PANE" ":edit $1" Enter ;;
      *)          tmux send-keys -t "$TARGET_PANE" " $1" ;;   # fall back: type the path at the prompt
    esac
    tmux select-pane -t "$TARGET_PANE"   # focus the editor after opening
    ;;
esac

exit 0
