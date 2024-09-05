fish_add_path ~/.cargo/bin

if status is-interactive

    type -q cargo-selector; and alias cr="cargo selector -i"

end
