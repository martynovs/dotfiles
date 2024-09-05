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
