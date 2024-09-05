if status is-interactive

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

end
