#!/bin/sh

build_prompt() {
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  ISSUE_ID=$(printf '%s' "$BRANCH" | grep -oE '^[0-9]+')
  if [ -n "$ISSUE_ID" ]; then
    PROMPT_PREFIX="Issue ID: #${ISSUE_ID}\nPrepend the issue id to the commit title like: ${ISSUE_ID}: <title>"
  else
    PROMPT_PREFIX=""
  fi
  printf '%b\n\nLimit all lines width to 100 characters max.\n\n%s' "$PROMPT_PREFIX" "$(cat)"
}

invoke_claude() {
  CLAUDECODE='' \
  MAX_THINKING_TOKENS=0 \
  HTTP_PROXY='http://127.0.0.1:12334' \
  HTTPS_PROXY='http://127.0.0.1:12334' \
  claude -p --no-session-persistence --model=haiku --tools='' --disable-slash-commands --setting-sources='' --system-prompt=''
}

use_tmux_popup() {
  # [ -n "$CLAUDECODE" ]
  return 0
}

open_editor() {
  _ed="${EDITOR:-code}"
  case "$(basename "${_ed%% *}")" in
    code)
      "$_ed" --wait "$1"
      ;;
    *)
      if [ -n "$TMUX" ] && use_tmux_popup; then
        tmux display-popup -E "\"$_ed\" \"$1\""
      else
        "$_ed" "$1" < /dev/tty > /dev/tty
      fi
      ;;
  esac
}

edit_in_editor() {
  f=$(mktemp)
  cat > "$f"
  open_editor "$f" || { rm -f "$f"; exit 1; }
  cat "$f"
  rm -f "$f"
}

build_prompt | invoke_claude | edit_in_editor
