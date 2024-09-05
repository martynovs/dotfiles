status is-interactive && test (uname) = Darwin && type -q ghostty && set -q GHOSTTY_RESOURCES_DIR || exit

abbr -a gbg 'ghostty-toggle-bg'

# alt-b (hold § + press b)
bind ∫ ghostty-toggle-bg

function ghostty-toggle-bg -d "Toggle Ghostty background opacity"
    set -l config_file (realpath ~/.config/ghostty/config 2>/dev/null)
    if test -z $config_file
        echo "Ghostty config file not found."
        return 127
    end
    sed -i '' -e '
        /^# *background-opacity/ {
            s/^# *//
            t end
        }
        /^background-opacity/ {
            s/^/# /
        }
        :end
    ' $config_file

    osascript -e '
        tell application "System Events"
            tell process "Ghostty"
                click menu item "Reload Configuration" of menu "Ghostty" of menu bar item "Ghostty" of menu bar 1
            end tell
        end tell' > /dev/null
end
