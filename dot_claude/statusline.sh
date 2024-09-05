#!/bin/bash
read -r input

{
  read -r MODEL
  read -r CWD
} < <(printf '%s' "$input" | jq -r '
  (.model.display_name // .model.id // ""),
  (.cwd // "")
')

GREEN=$'\033[01;32m'
YELLOW=$'\033[01;33m'
RED=$'\033[01;31m'
RESET=$'\033[00m'

GIT_ICON="${GREEN}${RESET}"
BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null)

if [ -n "$BRANCH" ]; then
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

  SUFFIX="${FILES% }"
  [ -n "$FILES" ] && [ -n "$LINES" ] && SUFFIX="${SUFFIX} | ${LINES}"
  [ -z "$FILES" ] && SUFFIX="$LINES"

  if [ -n "$SUFFIX" ]; then
    echo "[$MODEL] ${CWD##*/} | $GIT_ICON $BRANCH $SUFFIX"
  else
    echo "[$MODEL] ${CWD##*/} | $GIT_ICON $BRANCH"
  fi
else
  echo "[$MODEL] ${CWD##*/}"
fi
