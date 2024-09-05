status is-interactive || exit

# fix typos with '!'
type -q thefuck; and thefuck --alias ! | source

# press '?' to show help for command in commandline
bind \? ' eval " $(commandline --cut-at-cursor) --help | $HELP_LESS"; and commandline -f repaint'
test -z "$HELP_LESS"; and set -g HELP_LESS "less -R"

# useful shortcuts
abbr -a br brew
abbr -a bri "brew install"
abbr -a bro "brew info"
abbr -a brs "brew search"
type -q taproom; and alias bb taproom
abbr -a wh which

# terminal multiplexer
type -q zellij; and alias z zellij

# nice system info
type -q fastfetch; and alias info fastfetch

# weather report
type -q jq; and type -q bat; and type -q curl; and \
    abbr wttr "curl -s https://api.ip2location.io | jq -r '.city_name' | xargs -I {} curl -s http://wttr.in/{} | bat -p --paging=always"

# nice ls
type -q eza; and alias l "eza"; and alias ll "eza -lag"

# interactive du
type -q gdu-go; and alias du "gdu-go"

# nice df
type -q duf; and alias df duf
