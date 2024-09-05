status is-interactive || exit

# colored 'cat', 'man' and help
if type -q bat
    alias cat "bat -p"
    set -g HELP_LESS "bat -p -l help"
    set -gx MANPAGER "sh -c 'col -bx | bat -p -l man'"
end

type -q batman; and alias man batman

if type -q batpipe
    set -gx LESSOPEN "|($command -v batpipe) %s";
    set -ge LESSCLOSE;
    set -gx LESS "$LESS -R";
    set -gx BATPIPE "color";
end

# colored markdown preview
type -q glow; and alias md "glow -p"

# create slidev presentations
type -q bun; and alias slidev "bun create slidev"
