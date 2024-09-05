status is-interactive || exit

function colors -d "Preview a list of colors as swatches: color1[:description] [color2[:description] ...]"
    if not type -q pastel
        echo "pastel is not installed"
        return 1
    end

    # First pass: build labels and find max width
    set -l colors
    set -l labels
    set -l max_width 0
    for c in $argv
        # support color:"description" syntax, e.g. ff0000:"Pure Red"
        set parts (string split -m1 : -- $c)
        set c $parts[1]
        set label "  $c  "
        test -n "$parts[2]" && set label "  $c $parts[2]  "
        set colors $colors "$c"
        set labels $labels "$label"
        set w (string length -- "$label")
        test $w -gt $max_width && set max_width $w
    end

    # Second pass: render all blocks padded to uniform width (3 lines tall)
    set -l blank (string repeat -n $max_width ' ')
    for i in (seq (count $colors))
        set c $colors[$i]
        set fg (pastel textcolor "$c" | pastel format hex)
        pastel paint --on "$c" "$fg" "$blank"
        pastel paint --on "$c" "$fg" "$(string pad -r -w $max_width -- "$labels[$i]")"
        pastel paint --on "$c" "$fg" "$blank"
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
