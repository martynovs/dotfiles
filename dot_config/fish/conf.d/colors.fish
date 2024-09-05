status is-interactive || exit

# color manager
type -q pastel; and alias color pastel

function colors -d "Preview a list of colors as swatches" -a "color"
    # color  hex color value (with or without #), e.g. ff0000 or #ff0000
    #        accepts multiple colors: colors ff0000 00ff00 0000ff
    if not type -q pastel
        echo "pastel is not installed"
        return 1
    end
    for c in $argv
        # ensure # prefix (so callers can pass c02b35 or #c02b35)
        if not string match -q '#*' -- $c
            set c "#$c"
        end
        set fg (pastel textcolor "$c" | pastel format hex)
        pastel paint --on "$c" "$fg" "  $c  "
    end
    echo
end

# terminal theme manager
if type -q wallust
    function theme -d "change terminal theme" -a theme
        if test -z $theme
            set theme (__theme_list | fzf --prompt='Theme> ' --preview 'wallust theme -p {}' --preview-window='down:3:wrap')
        end
        test -z $theme; and return 1
        wallust theme -u $theme
    end

    function __theme_list
        wallust theme list | grep '^- ' | sed 's/^- //' | grep -vE '^(random|list) '
    end

    # Disable file completions for theme
    complete -f theme
    # Complete themes dynamically by running __theme_list
    complete -c theme -n '__fish_use_subcommand' -a '(__theme_list)'
end
