#!/bin/bash

dir=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")
# shellcheck source=installers/_helpers.sh
source "$dir/_helpers.sh"

header "Configuring askpass helper"
askpass_path="$HOME/.local/bin/askpass"
echo -e "#!/bin/sh\nsecurity find-generic-password -a \$USER -s login -gw" > "$askpass_path"
chmod +x "$askpass_path"


header "Configuring Hammerspoon"
defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"
