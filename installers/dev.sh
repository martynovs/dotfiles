#!/bin/bash

dir=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")
# shellcheck source=installers/_helpers.sh
source "$dir/_helpers.sh"


user_name=$(git config user.name || echo '')
user_email=$(git config user.email || echo '')

if [ -z "$user_name" ]; then
    header "Configure user name for git/jj commits"
    user_name=$(ask_input "Your user name for commits")
fi

if [ -z "$user_email" ]; then
    header "Configure email for git/jj commits"
    user_email=$(ask_input "Your email for commits")
fi


header "Configuring git"
if [ -z "$(git config get --global user.name)" ] && [ -n "$user_name" ]; then
    run "git config set --global user.name \"$user_name\""
fi
if [ -z "$(git config get --global user.email)" ] && [ -n "$user_email" ]; then
    run "git config set --global user.email \"$user_email\""
fi
if [ -z "$(git config get --global user.signingkey)" ]; then
    run "git config set --global user.signingkey ~/.ssh/id_ed25519.pub"
fi


header "Configuring jj"
touch "$(jj config path --user)"
if [ -z "$(jj config get user.name)" ] && [ -n "$user_name" ]; then
    run "jj config set --user user.name \"$user_name\""
fi
if [ -z "$(jj config get user.email)" ] && [ -n "$user_email" ]; then
    run "jj config set --user user.email \"$user_email\""
fi


header "Configuring tmux"
mkdir -p ~/.tmux
run "echo \"source ~/.config/tmux/tmux.conf\" > ~/.tmux.conf"
run "echo \"run $(brew --prefix)/opt/tpm/share/tpm/tpm\" > ~/.tmux/tmux.conf"
run "$(brew --prefix)/opt/tpm/share/tpm/bin/install_plugins"


header "Configuring cargo"
cargo_conf="$HOME/.cargo/config.toml"
mkdir -p "$(dirname "$cargo_conf")"
touch "$cargo_conf"
run "dasel put -f $cargo_conf -t string -v 'sccache' 'build.rustc-wrapper'"

# fix for packages that use pyO3
if is_macos; then
    if ! grep -q "\[target.aarch64-apple-darwin\]" "$cargo_conf"; then
        cat <<'EOF' >> "$cargo_conf"

[target.aarch64-apple-darwin]
rustflags = [
    "-C", "link-arg=-Wl,-dead_strip",            # Remove unused code
    "-C", "link-arg=-L/usr/local/lib",           # Add libunwind search path
    "-C", "link-arg=/usr/local/lib/libunwind.a", # Link static libunwind directly
]
EOF
    fi
fi
