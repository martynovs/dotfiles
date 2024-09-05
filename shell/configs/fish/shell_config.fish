# add aliases only on interactive mode
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

    # history management
    bind \e\[3\;5~ 'clear; commandline -f repaint' # ctrl + delete
    bind \e\[3\;9~ 'history clear' # cmd + delete

    # go to parent dir: cmd + backspace or opt + backspace
    bind \cU 'cd ..; commandline -f repaint'
    bind \e\x7F 'cd ..; commandline -f repaint'
    abbr -a -- - 'cd -'

    # start tmux: x, open dir in tmux: ctrl + x
    if type -q tmux
        alias x="tmux attach; or tmux"
        if type -q zoxide
            bind \cx __z_tmux_open_dir # ctrl + x
            function __z_tmux_open_dir
                set -l session_dir (zoxide query -i)
                if test $status -eq 0
                    tmux new-session -c $session_dir
                    commandline -f repaint
                end
            end
        end
        if type -q sesh
            bind \cx __sesh_tmux_open_dir # ctrl + x
            function __sesh_tmux_open_dir
                set -l tmux_session (sesh list | fzf)
                if test $status -eq 0
                    sesh connect $tmux_session
                end
            end
        end
    end

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
    type -q tree; and type -q bat; and alias t="tree -C | bat -p"
    type -q br; and abbr -a tt br

    # show disk usage
    type -q gdu-go; and alias du="gdu-go"

    # better 'loc'
    type -q tokei; and alias loc tokei

    # network state shortcuts
    alias opencons="lsof -PiTCP -s TCP:^LISTEN"
    alias openports="lsof -PiTCP -s TCP:LISTEN"

    # ssh menu
    type -q sshs; and abbr -a sss sshs

end
