status is-interactive || exit
type -q tmux || exit

# start tmux: x, open dir in tmux: ctrl + x
alias x "test -n \"$TMUX\"; and echo 'Already in tmux session'; or tmux attach; or tmux"

if type -q zoxide
    bind ctrl-x __z_tmux_open_dir
    function __z_tmux_open_dir
        set -l session_dir (zoxide query -i)
        if test $status -eq 0
            tmux new-session -c $session_dir
            commandline -f repaint
        end
    end
end

if type -q sesh
    bind ctrl-x __sesh_tmux_open_dir
    function __sesh_tmux_open_dir
        set -l tmux_session (sesh list | fzf)
        if test $status -eq 0
            sesh connect $tmux_session
        end
    end
end
