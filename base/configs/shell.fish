if status is-interactive

    # fix ghostty TERM
    [ "$TERM" = "xterm-ghostty" ]; and set -gx TERM "xterm-256color"

    # nice prompt
    type -q starship; and starship init fish | source

    function print_exit_error_code --on-event fish_postexec
        set -l code $status
        if test $code -ne 0
            set -l red (set_color --bold red)
            set -l norm (set_color normal)
            echo "Exit code: $red$code$norm"
        end
    end    

    # editor
    type -q code; and abbr -a c. "code ."; and set -gx EDITOR code
    type -q nvim; and alias v nvim; and set -gx EDITOR nvim

    # switch from shell to background task (works with nvim and tmux)
    bind ctrl-z "fg 2>/dev/null; commandline -f repaint"

    # useful shortcuts
    abbr -a -- - "cd -"
    abbr -a -- +x "chmod +x"
    abbr -a my "chown -R \$(whoami)"
    abbr -a rf "rm -rf"

    # smart cd
    if type -q zoxide
        zoxide init fish --no-cmd | source
        # go to dir from history
        bind ctrl-q "__zoxide_zi; commandline -f repaint"
        alias cd __zoxide_z
        set -gx _ZO_FZF_OPTS
    end

    # smart find
    if type -q fzf
        type -q eza; and set fzf_preview_dir_cmd "eza -l --all --color=always --icons=always"
        type -q bat; and set fzf_preview_file_cmd "bat -p --color=always --theme='gruvbox-dark' --line-range :500"
        fzf_configure_bindings \
            --history='ctrl-r' \
            --directory='ctrl-f,ctrl-d' \
            --processes='ctrl-f,ctrl-a' \
            --variables='ctrl-f,ctrl-e' \
            --git_status='ctrl-f,ctrl-g' \
            --git_log='ctrl-f,ctrl-s'
    end

    type -q fastfetch; and alias info fastfetch

    # colored 'cat', 'man' and help
    if type -q bat
        alias cat "bat -p"

        bind \? 'commandline -r "h $(commandline)"'
        function h
            $argv --help | bat -p -l help
        end

        type -q batman; and alias man batman
        set -gx MANPAGER "sh -c 'col -bx | bat -p -l man'"
    end

    if type -q batpipe
        set -x LESSOPEN "|($command -v batpipe) %s";
        set -e LESSCLOSE;
        set -x LESS "$LESS -R";
        set -x BATPIPE "color";
    end

    # colored 'ls'
    if type -q eza
        alias l "eza"
        alias ll "eza -lag"
    end

    # colored markdown preview
    type -q glow; and alias md "glow -p"

    # dir tree
    type -q br; and alias t "br -g"

    # disk usage
    type -q gdu-go; and alias du "gdu-go"

    # better 'loc'
    type -q tokei; and alias loc tokei

    type -q xh; and ! type -q wget; and alias wget "xh -dF"

    # network state shortcuts
    alias opencons "lsof -PiTCP -s TCP:^LISTEN"
    alias openports "lsof -PiTCP -s TCP:LISTEN"

end
