status is-interactive || exit

# fix typos with '!'
type -q thefuck; and thefuck --alias ! | source

# press '?' to show help for command in commandline
bind \? ' help $(commandline --cut-at-cursor); and commandline -f repaint'
function help -d "show help for command"
    eval " $argv --help | $HELP_LESS"
end
test -z "$HELP_LESS"; and set -g HELP_LESS "less -R"

# useful shortcuts
abbr -a br brew
abbr -a wh which

# terminal multiplexer
type -q zellij; and alias z zellij

# nice system info
type -q fastfetch; and alias info fastfetch

# nice ls
type -q eza; and alias l "eza"; and alias ll "eza -lag"

# interactive du
type -q gdu-go; and alias du "gdu-go"

# nice df
type -q duf; and alias df duf
