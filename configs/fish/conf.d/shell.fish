# remove greeting
set -g fish_greeting

status is-interactive || exit

# fix ghostty TERM
[ "$TERM" = "xterm-ghostty" ]; and set -gx TERM "xterm-256color"

# nice prompt
if type -q starship
    function starship_transient_prompt_func
        starship module character
    end
    function starship_transient_rprompt_func
        starship module time
    end
    starship init fish | source
    enable_transience
end

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

# editor
type -q code; and abbr -a c. "code ."; and set -gx EDITOR code
type -q nvim; and alias v nvim; and set -gx EDITOR nvim
type -q hx;   and alias e hx;   and set -gx EDITOR hx

# ctrl-t to translate natural language to shell command
if type -q q
    bind ctrl-t 'test -z (commandline); and q translate; or t (commandline)'

    function t -d "translate natural language to shell command" -a input
        set -l tmpfile (mktemp)
        set -l input (string join ' ' $argv)
        eval echo "$input" | q translate > $tmpfile &
        set -l bg_pid $last_pid
        set -l spin_chars (string split '' '⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏')
        set -l count (count $spin_chars)
        set -l i 1
        while kill -0 $bg_pid >/dev/null 2>&1
            printf "\r\033[1C%s" $spin_chars[$i] >&2
            sleep 0.1
            set i (math "($i % $count) + 1")
        end
        printf "\r\033[1C " >&2  # Clear the line
        wait $bg_pid
        set -l cmd (cat $tmpfile)
        rm $tmpfile
        commandline -r "$cmd "
        commandline -f repaint
    end
end
