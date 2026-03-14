#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
CWD=$(echo "$input" | jq -r '.cwd // empty')

RESET='\033[0m'
DIM='\033[2m'
WHITE='\033[37m'
YELLOW='\033[33m'
RED='\033[31m'

# 0-32%: white (safe), 32-55%: yellow (caution), 55%+: red (critical)
if [ "$PCT" -ge 55 ]; then COLOR="$RED"
elif [ "$PCT" -ge 32 ]; then COLOR="$YELLOW"
else COLOR="$WHITE"; fi

# Shorten home dir to ~
SHORT_CWD="${CWD/#$HOME/~}"

SEP="${DIM}  ||  ${RESET}"
echo -e "${COLOR}Context - ${PCT}%${RESET}${SEP}${DIM}${MODEL}${RESET}${SEP}${WHITE}${SHORT_CWD}${RESET}"
