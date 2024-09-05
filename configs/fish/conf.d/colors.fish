status is-interactive || exit

# color manager
type -q pastel; and alias color pastel

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
