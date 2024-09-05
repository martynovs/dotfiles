# remove greeting
set -g fish_greeting

status is-interactive || exit

# fix ghostty TERM
[ "$TERM" = "xterm-ghostty" ]; and set -gx TERM "xterm-256color"

# nice prompt
type -q starship; and starship init fish | source

# nice system info
type -q fastfetch; and alias info fastfetch

# show exit code if command failed with error
function print_exit_error_code --on-event fish_postexec
    set -l code $status
    if test $code -ne 0
        set -l red (set_color --bold red)
        set -l norm (set_color normal)
        echo "Exit code: $red$code$norm"
    end
end    

# very useful alias
alias br brew

# fix typos with '!'
type -q thefuck; and thefuck --alias ! | source

# editor
type -q code; and abbr -a c. "code ."; and set -gx EDITOR code
type -q nvim; and alias v nvim; and set -gx EDITOR nvim
type -q hx;   and alias e hx;   and set -gx EDITOR hx

# switch from shell to background task (works with nvim and tmux)
bind ctrl-z "fg 2>/dev/null; commandline -f repaint"

# press '?' to show help for command in commandline
bind \? ' help $(commandline --cut-at-cursor); and commandline -f repaint'
function help -d "show help for command"
    eval " $argv --help | $HELP_LESS"
end
test -z "$HELP_LESS"; and set -g HELP_LESS "less -R"

# useful shortcuts
abbr -a -- - "cd -"
abbr -a -- +x "chmod +x"
abbr -a my "chown -R \$(whoami)"
abbr -a rf "rm -rf"

# nice ls
if type -q eza
    alias l "eza"
    alias ll "eza -lag"
end

# interactive du
type -q gdu-go; and alias du "gdu-go"

# nice df
type -q duf; and alias df duf
