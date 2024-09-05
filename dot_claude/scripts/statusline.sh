#!/bin/bash
read -r input
{
  read -r MODEL
  read -r EFFORT
  read -r CWD
  read -r CTX_USED
} < <(printf '%s' "$input" | jq -r '
  (.model.display_name // .model.id // ""),
  (.effort.level // ""),
  (.cwd // ""),
  (.context_window.used_percentage // 0)
')

CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

MODEL=$(printf '%s' "$MODEL" | sed 's/ *(.*)//; s/ .*//')
[ -n "$EFFORT" ] && MODEL="${MODEL}:${EFFORT}"

GREY=$'\033[01;38;2;180;180;180m'
GREEN=$'\033[01;38;2;74;158;106m'
BLUE=$'\033[01;38;2;97;175;239m'
YELLOW=$'\033[01;33m'
RED=$'\033[01;31m'
RESET=$'\033[00m'

color_for_pct() {
  local pct="${1:-0}"
  if [ "$pct" -ge 85 ]; then printf '%s' "$RED"
  elif [ "$pct" -ge 70 ]; then printf '%s' "$YELLOW"
  elif [ "$pct" -ge 50 ]; then printf '%s' "$GREEN"
  else printf '%s' "$GREY"
  fi
}

CTX_INFO="$(color_for_pct "$CTX_USED")${CTX_USED}%${RESET}"

GIT_INFO=""
GIT_BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null)
if [ -n "$GIT_BRANCH" ]; then
  case "$(git -C "$CWD" rev-parse --git-dir 2>/dev/null)" in
    *"/worktrees/"*) GIT_ICON="⎇" ;;
    *) GIT_ICON="" ;;
  esac

  PORCELAIN=$(git -C "$CWD" status --porcelain 2>/dev/null)

  STAGED=$(printf '%s\n' "$PORCELAIN" | grep -cE '^[^? ]' || true)
  MODIFIED=$(printf '%s\n' "$PORCELAIN" | grep -cE '^ M' || true)
  DELETED=$(printf '%s\n' "$PORCELAIN" | grep -cE '^ D' || true)
  UNTRACKED=$(printf '%s\n' "$PORCELAIN" | grep -cE '^\?\?' || true)

  read -r ADDED REMOVED < <(
    git -C "$CWD" diff HEAD --numstat 2>/dev/null |
    awk '{a+=$1; r+=$2} END {print a+0, r+0}'
  )

  # Untracked files are invisible to `git diff`, so count their lines separately
  # (respecting .gitignore via --exclude-standard). Kept out of the tracked total.
  UNTRACKED_ADDED=0
  if [ "${UNTRACKED:-0}" -gt 0 ]; then
    UNTRACKED_ADDED=$(
      cd "$CWD" 2>/dev/null &&
      git ls-files --others --exclude-standard -z 2>/dev/null |
      xargs -0 cat 2>/dev/null | wc -l | tr -d ' '
    )
  fi

  FILES=""
  [ "${STAGED:-0}" -gt 0 ]    && FILES="${FILES}${GREEN}+${STAGED}${RESET} "
  [ "${MODIFIED:-0}" -gt 0 ]  && FILES="${FILES}${YELLOW}~${MODIFIED}${RESET} "
  [ "${DELETED:-0}" -gt 0 ]   && FILES="${FILES}${RED}-${DELETED}${RESET} "
  [ "${UNTRACKED:-0}" -gt 0 ] && FILES="${FILES}${BLUE}?${UNTRACKED}${RESET} "

  LINES=""
  [ "${ADDED:-0}" -gt 0 ]           && LINES="${GREEN}+${ADDED}${RESET}"
  [ "${REMOVED:-0}" -gt 0 ]         && LINES="${LINES} ${RED}-${REMOVED}${RESET}"
  [ "${UNTRACKED_ADDED:-0}" -gt 0 ] && LINES="${LINES:+$LINES }${BLUE}+${UNTRACKED_ADDED}${RESET}"

  GIT_STATE="${FILES% }"
  [ -n "$FILES" ] && [ -n "$LINES" ] && GIT_STATE="${GIT_STATE} : ${LINES}"
  [ -z "$FILES" ] && GIT_STATE="$LINES"

  [ "${#GIT_BRANCH}" -gt 33 ] && GIT_BRANCH="${GIT_BRANCH:0:32}…"

  GIT_INFO="${GREEN}$GIT_ICON${RESET} $GIT_BRANCH${GIT_STATE:+ $GIT_STATE}"
fi

format_cwd() {
  local cwd="$1" max_len="${2:-4}"
  if [ "$cwd" = "$HOME" ]; then
    printf '~'; return
  elif [ "$cwd" = "/" ]; then
    printf '/'; return
  fi
  local prefix="" rel=""
  if [ "${cwd#"$HOME"/}" != "$cwd" ]; then
    prefix="~"; rel="${cwd#"$HOME"/}"
  else
    prefix=""; rel="${cwd#/}"
  fi
  local IFS='/'
  # shellcheck disable=SC2206
  local parts=($rel)
  local n="${#parts[@]}" result="$prefix" i
  for (( i=0; i<n-1; i++ )); do
    if [ "${#parts[$i]}" -gt "$max_len" ]; then
      result="${result}/${parts[$i]:0:$(( max_len - 1 ))}…"
    else
      result="${result}/${parts[$i]}"
    fi
  done
  result="${result}/${parts[$((n-1))]}"
  printf '%s' "$result"
}

_CONF_BASE="$HOME/.claude-"
CONF="${CONFIG_DIR/#"$_CONF_BASE"/}"
[ "$CONF" = "$CONFIG_DIR" ] && CONF=""

CWD_CLEAN=$(printf '%s' "$CWD" | sed 's|/.worktrees/[^/]*||')
# format_cwd kept for later; skip dir shortening for now — just do ~ substitution
CWD_DISPLAY="${CWD_CLEAN:-$CWD}"
# shellcheck disable=SC2088  # literal ~ for display, expansion not wanted
case "$CWD_DISPLAY" in
  "$HOME") CWD_DISPLAY="~" ;;
  "$HOME"/*) CWD_DISPLAY="~/${CWD_DISPLAY#"$HOME"/}" ;;
esac

echo "${CONF:+$CONF:}$MODEL $CTX_INFO | $CWD_DISPLAY${GIT_INFO:+ | $GIT_INFO}"
