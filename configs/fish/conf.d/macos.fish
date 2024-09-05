status is-interactive && test (uname) = Darwin || exit

if type -q askpass
    set -gx SUDO_ASKPASS (command -v askpass)

    function set-askpass-password -d "Set askpass password"
        security delete-generic-password -a $USER -s login > /dev/null 2>&1
        security add-generic-password -a $USER -s login -w
    end 
end

function app-bless -d "Remove application from quarantine" -a path
    test -z $path && echo "Usage: app-bless <path>" && return 127
    if test -d $path
        sudo xattr -d com.apple.quarantine $path
    else
        echo "App directory not found: $path"
        return 127
    end
end

abbr -a gbg 'ghostty-toggle-bg'

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
