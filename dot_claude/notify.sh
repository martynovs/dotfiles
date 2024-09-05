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

  tmux set-option -g @claude-status " #[fg=yellow]⚡"
  tmux set-option -g @claude-focus-window "$source_info"
  tmux set-window-option -t "${source_id}" @claude_attention "1"
  local current_name
  current_name=$(tmux display-message -t "${source_id}" -p '#{window_name}' 2>/dev/null)
  if [[ "$current_name" != *" •" ]]; then
    tmux rename-window -t "${source_id}" "${current_name} •"
  fi
  tmux set-buffer -b claude -a "[$(date '+%H:%M:%S')] [${source_session_name}:${source_window_index}] $1: $2
"

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

ask_permission() {
  local title="$1"
  local message="$2"

  local result
  result=$(osascript -e "display alert \"$title\" message \"$message\" buttons {\"Deny\", \"Allow\"} default button \"Allow\" cancel button \"Deny\" giving up after 30" 2>&1)

  if echo "$result" | grep -q "Allow"; then
    echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
  else
    echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"deny","message":"User denied the request"}}}'
    if [ -n "${TMUX_PANE:-}" ]; then
      local pane_info
      pane_info=$(tmux display-message -t "${TMUX_PANE}" -p '#{session_name}:#{window_index}' 2>/dev/null)
      tmux_notify "$title" "$message" && return
    fi
  fi
}

case "$1" in
  permission)
    DATA=$(cat)
    MSG=$(echo "$DATA" | jq -r '.tool_input.description // empty')
    notify "Permission requested" "$MSG"
    # TOOL=$(echo "$DATA" | jq -r '.tool_name // "unknown"')
    # MSG=$(echo "$DATA" | jq -r '
    #   if .tool_name == "Bash" then .tool_input.command
    #   elif .tool_input.file_path then .tool_input.file_path
    #   else (.tool_input | to_entries | map(.key + ": " + (.value | tostring)) | join("\n"))
    #   end // ""')
    # ask_permission "$TOOL" "$MSG"
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
