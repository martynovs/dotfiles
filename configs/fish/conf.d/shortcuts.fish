status is-interactive || exit

# fix typos with '!'
type -q thefuck; and thefuck --alias ! | source

# nice system info
type -q fastfetch; and alias info fastfetch

# press '?' to show help for command in commandline
bind \? 'test -z "$HELP_LESS"; and set -l HELP_LESS "less -R"; \
         set -l cmd (commandline --cut-at-cursor); \
         test -n "$cmd"; and eval "$cmd --help | $HELP_LESS"; \
         commandline -f repaint'

# switch from shell to background task (works with hx/nvim/tmux)
bind ctrl-z "fg 2>/dev/null; commandline -f repaint"

# editor
type -q code; and abbr -a c. "code ."; and set -gx EDITOR code
type -q nvim; and alias v nvim; and set -gx EDITOR nvim
type -q hx;   and alias e hx;   and set -gx EDITOR hx

if type -q brew
    abbr -a br brew
    abbr -a bri "brew install"
    abbr -a bro "brew info"
    abbr -a brs "brew search"
    type -q taproom; and alias bb taproom
end

# colored markdown preview
type -q glow; and alias md "glow -p"

# create slidev presentations
alias slidev_create "npm create slidev"
