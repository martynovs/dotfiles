if status is-interactive

    # nice prompt
    type -q starship; and starship init fish | source

    # editor
    type -q code; and abbr -a c. "code ."; and set -gx EDITOR code
    type -q hx; and alias v=hx; and set -gx EDITOR hx
    type -q nvim; and alias v=nvim; and set -gx EDITOR nvim

    # smart cd
    if type -q zoxide
        zoxide init fish | source
        # go to dir from history: ctrl + o
        bind \co __zoxide_zi
        alias cd=z
        abbr -a c cd
        set -gx _ZO_FZF_OPTS
    end

    # smart find
    if type -q fzf
        fzf_configure_bindings --directory=\cf --processes=\cP --variables=\e\cV
        type -q eza; and set fzf_preview_dir_cmd "eza -l --all --color=always --icons=always"
        type -q bat; and set fzf_preview_file_cmd "bat -p --color=always --theme='Catppuccin Frappe' --line-range :500"
    end

    # switch between running cli app and shell
    bind \cz 'fg 2>/dev/null; commandline -f repaint' # ctrl + z

    # clear screen
    bind ctrl-h 'clear; commandline -f repaint' # ctrl + backspace

    # go to parent dir
    bind \cU 'cd ..; commandline -f repaint' # cmd + backspace
    abbr -a -- - 'cd -'

    # useful shortcuts
    abbr -a -- +x "chmod +x"
    abbr -a cho "chown -R \$(whoami)"
    abbr -a rf "rm -rf"

    # colored 'cat', 'man' and help
    if type -q bat
        alias cat="bat -p"

        bind \? 'commandline -r "h $(commandline)"'
        function h
            $argv --help | bat -p -l help
        end

        set -gx MANPAGER "sh -c 'col -bx | bat -p -l man'"

        if type -q fzf
            function bat-theme
                bat --list-themes | fzf --preview="bat --theme={} --color=always $argv"
            end
        end
    end

    # colored 'ls'
    if type -q eza
        alias l="eza"
        alias ll="eza -lag"
    end

    # show dir tree
    type -q br; and alias t="br -g"

    # show disk usage
    type -q gdu-go; and alias du="gdu-go"

    # better 'loc'
    type -q tokei; and alias loc tokei

    # network state shortcuts
    alias opencons="lsof -PiTCP -s TCP:^LISTEN"
    alias openports="lsof -PiTCP -s TCP:LISTEN"

    # ssh menu
    type -q sshs; and abbr -a ss sshs

end
