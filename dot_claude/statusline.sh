#!/bin/bash
read -r input
{
  read -r MODEL
  read -r CWD
  read -r CTX_USED
  read -r CTX_CONSUMED
} < <(printf '%s' "$input" | jq -r '
  (.model.display_name // .model.id // ""),
  (.cwd // ""),
  (.context_window.used_percentage // 0),
  ((.context_window.current_usage.input_tokens // 0) + 
   (.context_window.current_usage.output_tokens // 0) + 
   (.context_window.current_usage.cache_creation_input_tokens // 0) + 
   (.context_window.current_usage.cache_read_input_tokens // 0))
')

MODEL=$(printf '%s' "$MODEL" | sed 's/\([A-Za-z]\)[a-z]* \(.*\)/\1:\2/')

GREY=$'\033[01;38;2;180;180;180m'
GREEN=$'\033[01;38;2;74;158;106m'
YELLOW=$'\033[01;33m'
RED=$'\033[01;31m'
RESET=$'\033[00m'

color_for_pct() {
  local pct="${1:-0}"
  if [ "$pct" -ge 70 ]; then printf '%s' "$RED"
  elif [ "$pct" -ge 55 ]; then printf '%s' "$YELLOW"
  elif [ "$pct" -ge 35 ]; then printf '%s' "$GREEN"
  else printf '%s' "$GREY"
  fi
}

color_for_pace() {
  local pct="${1:-0}" resets_at="$2"
  local ts mins_remaining time_elapsed_pct pace_delta
  ts=$(date -j -f "%Y-%m-%dT%H:%M:%S%z" \
    "$(printf '%s' "$resets_at" | sed 's/\.[0-9]*//; s/:\([0-9][0-9]\)$/\1/')" \
    +%s 2>/dev/null)
  if [ -z "$ts" ]; then
    color_for_pct "$pct"; return
  fi
  mins_remaining=$(( (ts - $(date +%s)) / 60 ))
  [ "$mins_remaining" -lt 0 ] && mins_remaining=0
  time_elapsed_pct=$(( (10080 - mins_remaining) * 100 / 10080 ))
  pace_delta=$(( pct - time_elapsed_pct ))
  if   [ "$pace_delta" -gt 25 ]; then printf '%s' "$RED"
  elif [ "$pace_delta" -gt 10 ]; then printf '%s' "$YELLOW"
  elif [ "$pace_delta" -gt -10 ]; then printf '%s' "$GREEN"
  else printf '%s' "$GREY"
  fi
}

format_time_left() {
  local resets_at="$1"
  local ts mins
  ts=$(date -j -f "%Y-%m-%dT%H:%M:%S%z" "$(printf '%s' "$resets_at" | sed 's/\.[0-9]*//; s/:\([0-9][0-9]\)$/\1/')" +%s 2>/dev/null)
  [ -z "$ts" ] && return
  mins=$(( (ts - $(date +%s)) / 60 ))
  [ "$mins" -le 0 ] && return
  if [ "$mins" -ge 1440 ]; then
    printf ' (%dd %dh)' "$((mins / 1440))" "$(( (mins % 1440) / 60 ))"
  elif [ "$mins" -ge 60 ]; then
    printf ' (%d:%02d)' "$((mins / 60))" "$((mins % 60))"
  else
    printf ' (%dm)' "$mins"
  fi
}

format_size() {
  local n="${1:-0}"
  if [ "$n" -ge 1000000 ]; then printf '%s' "$((n / 1000000))M"
  elif [ "$n" -ge 1000 ]; then printf '%s' "$((n / 1000))k"
  else printf '%s' "$n"
  fi
}

CTX_INFO="$(color_for_pct "$CTX_USED")${CTX_USED}%${RESET} $(format_size "$CTX_CONSUMED")"

USAGE_LIMITS=""
USAGE_CACHE="/tmp/claude/claude_usage_cache${CLAUDE_CREDS_SUFFIX}"
CACHE_MTIME=$(stat -f %m "$USAGE_CACHE" 2>/dev/null || echo 0)
if [ $(( $(date +%s) - CACHE_MTIME )) -gt 600 ]; then
  TOKEN=$(security find-generic-password -s "Claude Code-credentials${CLAUDE_CREDS_SUFFIX:+-$CLAUDE_CREDS_SUFFIX}" -w 2>/dev/null | jq -r '.claudeAiOauth.accessToken // empty')
  if [ -n "$TOKEN" ]; then
    USAGE_JSON=$(curl -s ${HTTP_PROXY:+--proxy "$HTTP_PROXY"} \
      -H "Authorization: Bearer $TOKEN" \
      -H "User-Agent: claude-code/$(claude -v 2>/dev/null | cut -d' ' -f1)" \
      -H "anthropic-beta: oauth-2025-04-20" \
      https://api.anthropic.com/api/oauth/usage 2>/dev/null)
    if printf '%s' "$USAGE_JSON" | jq -e 'has("five_hour") or has("seven_day")' >/dev/null 2>&1; then
      mkdir -p "$(dirname "$USAGE_CACHE")"
      printf '%s' "$USAGE_JSON" > "$USAGE_CACHE"
    fi
  fi
fi

if [ -f "$USAGE_CACHE" ]; then
  USAGE_JSON=$(cat "$USAGE_CACHE")
  FIVE_HOUR_UTIL=$(printf '%s' "$USAGE_JSON" | jq -r '.five_hour.utilization // empty')
  FIVE_HOUR_RESET=$(printf '%s' "$USAGE_JSON" | jq -r '.five_hour.resets_at // empty')
  SEVEN_DAY_UTIL=$(printf '%s' "$USAGE_JSON" | jq -r '.seven_day.utilization // empty')
  SEVEN_DAY_RESET=$(printf '%s' "$USAGE_JSON" | jq -r '.seven_day.resets_at // empty')
  if [ -n "$FIVE_HOUR_UTIL" ]; then
    PCT=${FIVE_HOUR_UTIL%.*}
    FIVE_HOUR_LIMIT="$(color_for_pct "$PCT")5h:${PCT}%$(format_time_left "$FIVE_HOUR_RESET")${RESET}"
  fi
  if [ -n "$SEVEN_DAY_UTIL" ]; then
    PCT=${SEVEN_DAY_UTIL%.*}
    SEVEN_DAY_LIMIT="$(color_for_pace "$PCT" "$SEVEN_DAY_RESET")7d:${PCT}%$(format_time_left "$SEVEN_DAY_RESET")${RESET}"
  fi
  if [ -n "$FIVE_HOUR_LIMIT" ] && [ -n "$SEVEN_DAY_LIMIT" ]; then
    USAGE_LIMITS="$FIVE_HOUR_LIMIT $SEVEN_DAY_LIMIT"
  else
    USAGE_LIMITS="$SEVEN_DAY_LIMIT"
  fi
fi

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

  read -r ADDED REMOVED < <(
    git -C "$CWD" diff HEAD --numstat 2>/dev/null |
    awk '{a+=$1; r+=$2} END {print a+0, r+0}'
  )

  FILES=""
  [ "${STAGED:-0}" -gt 0 ]   && FILES="${FILES}${GREEN}+${STAGED}${RESET} "
  [ "${MODIFIED:-0}" -gt 0 ] && FILES="${FILES}${YELLOW}~${MODIFIED}${RESET} "
  [ "${DELETED:-0}" -gt 0 ]  && FILES="${FILES}${RED}-${DELETED}${RESET} "

  LINES=""
  [ "${ADDED:-0}" -gt 0 ]   && LINES="${GREEN}+${ADDED}${RESET}"
  [ "${REMOVED:-0}" -gt 0 ] && LINES="${LINES} ${RED}-${REMOVED}${RESET}"

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

CWD_CLEAN=$(printf '%s' "$CWD" | sed 's|/.worktrees/[^/]*||')
CWD_DISPLAY=$(format_cwd "${CWD_CLEAN:-$CWD}")
TIME=$(date +%H:%M)

echo "$MODEL $CTX_INFO | $CWD_DISPLAY${GIT_INFO:+ | $GIT_INFO}${USAGE_LIMITS:+ | Usage: $USAGE_LIMITS}"
