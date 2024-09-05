#!/bin/bash

header() { echo; echo -e "\033[1m\033[0;32m$1\033[0m"; }
run() { echo "$1"; eval "$1"; }
is_macos() { [[ $OSTYPE == "darwin"* ]]; }
installed() { [ -x "$(command -v "$1")" ]; }
sudo_prefix() { [[ $EUID -eq 0 ]] && echo "" || echo "sudo "; }


ask_confirmation() {
    local timeout=${2:-10}
    if command -v gum >/dev/null; then
        gum confirm "$1" --default=no --timeout="${timeout}s" || return 1;
    else
        if ! read -t "$timeout" -p "$1 (y/N): " -r answer; then
            if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
                return 1;
            fi
        else
            return 1;
        fi
    fi
}


ask_input() {
    local timeout=${2:-10}
    local limit=${3:-100}
    local answer
    if command -v gum >/dev/null; then
        answer=$(gum input --placeholder="$1" --char-limit="$limit" --timeout="${timeout}s");
    else
        if ! read -t "$timeout" -p "$1: " -r answer; then
            echo -e "\n\ntimed out" 1>&2
        fi
    fi
    echo "$answer"
}
