#!/bin/bash
# Usage: notify.sh <event_type>
# event_type: stop | subagent | notification | permission | open

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

ICON="file://$HOME/.claude/claude.png"

tmux_notify() {
  local pane_info
  pane_info=$(tmux display-message -t "${TMUX_PANE}" -p '#{session_id}|#{window_id}|#{session_name}|#{window_index}' 2>/dev/null)
  local source_session_id source_window_id source_session_name source_window_index
  source_session_id=$(echo "$pane_info" | cut -d'|' -f1)
  source_window_id=$(echo "$pane_info" | cut -d'|' -f2)
  source_session_name=$(echo "$pane_info" | cut -d'|' -f3)
  source_window_index=$(echo "$pane_info" | cut -d'|' -f4)
  local source_id="${source_session_id}:${source_window_id}"
  local source_info="${source_session_name}:${source_window_index}"

  local focused_line focused_id focused_client
  focused_line=$(tmux list-clients -F '#{client_flags}|#{client_name}|#{session_id}:#{window_id}' 2>/dev/null | grep 'focused' | head -1)
  focused_id=$(echo "$focused_line" | cut -d'|' -f3)
  focused_client=$(echo "$focused_line" | cut -d'|' -f2)

  local term_windows
  term_windows=$(osascript -e 'tell application "System Events" to tell process "Ghostty" to count of windows' 2>/dev/null)

  # Same window, user sees it in terminal — do nothing
  [ "$term_windows" -gt "0" ] && [ "$source_id" = "$focused_id" ] && return 0

  local display_msg
  if [ "${source_id%%:*}" = "${focused_id%%:*}" ]; then
    display_msg="(#[fg=cyan]${source_window_index}#[default]) $1: $2"
  else
    display_msg="(#[fg=yellow]${source_session_name}#[default]:#[fg=cyan]${source_window_index}#[default]) $1: $2"
  fi
  tmux set-option -g @claude-status " #[fg=yellow]⚡ Claude"
  tmux set-option -g @claude-focus-window "$source_info"
  tmux display-message -c "$focused_client" -d 4000 "$display_msg"
  tmux set-buffer -b claude -a "[$(date '+%H:%M:%S')] [${source_session_name}:${source_window_index}] $1: $2
"

  # Terminal has no windows — switch to tmux source window, user will see it when open terminal
  [ "$term_windows" -le "1" ] && tmux switch-client -c "$focused_client" -t "$source_info"

  # Open system notification
  return 1
}

notify() {
  local title="$1"
  local message="$2"
  if [ -n "${TMUX_PANE:-}" ]; then
    local pane_info
    pane_info=$(tmux display-message -t "${TMUX_PANE}" -p '#{session_name}:#{window_index}' 2>/dev/null)
    tmux_notify "$title" "$message" && return
    title="$title (${pane_info})"
  fi
  local execute="osascript -e 'tell application \"Ghostty\" to perform action \"toggle_quick_terminal\" on terminal 1'"
  terminal-notifier -title "$title" -message "$message" -contentImage "$ICON" -group "claude-code" -execute "$execute"
}

case "$1" in
  permission)
    DATA=$(cat)
    MSG=$(echo "$DATA" | jq -r '.tool_input.description // empty')
    notify "Permission requested" "$MSG"
    ;;
  notification)
    DATA=$(cat)
    TITLE=$(echo "$DATA" | jq -r '.title // "Claude"')
    MSG=$(echo "$DATA" | jq -r '.message // "Notification"')
    notify "$TITLE" "$MSG"
    ;;
  task_completed)
    DATA=$(cat)
    TITLE=$(echo "$DATA" | jq -r '.task_subject // empty')
    MSG=$(echo "$DATA" | jq -r '.task_description // empty')
    notify "Completed: $TITLE" "$MSG"
    ;;
  stop)
    DATA=$(cat)
    MSG=$(echo "$DATA" | jq -r '.last_assistant_message // empty')
    notify 'Finished' "$MSG"
    ;;
esac
