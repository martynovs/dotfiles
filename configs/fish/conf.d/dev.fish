if command -q direnv
    direnv hook fish | source
    set -g direnv_fish_mode eval_on_arrow
end

status is-interactive || exit

# build runners
type -q just; and alias ju just
type -q mask; and alias mk mask

# interactive json/yaml preview
if type -q fx
    set -gx FX_THEME '3'
    alias json fx
    alias yaml "fx --yaml"
end

# color manager
type -q pastel; and alias color pastel

# colorized log viewer
type -q tspin; and alias log tspin

# better 'loc'
type -q tokei; and alias loc tokei
