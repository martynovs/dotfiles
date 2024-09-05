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


header "Configuring Rectangle"
# Modifier flag masks (NSEvent): ctrl=262144 opt=524288 cmd=1048576 shift=131072
# ctrl+opt+cmd = 262144 + 524288 + 1048576 = 1835008
# Key codes: left arrow=123, right arrow=124
rect_mods=1835008
# Move focused window to the next/previous monitor.
defaults write com.knollsoft.Rectangle nextDisplay -dict keyCode -int 124 modifierFlags -int "$rect_mods"
defaults write com.knollsoft.Rectangle previousDisplay -dict keyCode -int 123 modifierFlags -int "$rect_mods"
# Baseline preferences.
defaults write com.knollsoft.Rectangle launchOnLogin -bool true
defaults write com.knollsoft.Rectangle SUEnableAutomaticChecks -bool false
# Reload so shortcuts apply without a manual restart.
if pgrep -xq Rectangle; then
    killall Rectangle && open -a Rectangle
fi
