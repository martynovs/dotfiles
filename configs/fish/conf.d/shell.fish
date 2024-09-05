# remove greeting
set -g fish_greeting

status is-interactive || exit

# fix ghostty TERM
[ "$TERM" = "xterm-ghostty" ]; and set -gx TERM "xterm-256color"

# nice prompt
type -q starship; and starship init fish | source

# show exit code if command failed with error
function print_exit_error_code --on-event fish_postexec
    set -l code $status
    if test $code -ne 0
        set -l red (set_color --bold red)
        set -l norm (set_color normal)
        echo "Exit code: $red$code$norm"
    end
end    

# switch from shell to background task (works with hx/nvim/tmux)
bind ctrl-z "fg 2>/dev/null; commandline -f repaint"
