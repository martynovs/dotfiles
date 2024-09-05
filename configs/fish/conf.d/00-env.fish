set -gx XDG_CONFIG_HOME ~/.config
set -gx XDG_CACHE_HOME ~/.cache

set -gx GOPATH ~/.go
fish_add_path ~/.go/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin
fish_add_path ~/.dotnet/tools

# add Homebrew env
set brew_dir (__fish_brew_home)
eval ($brew_dir/bin/brew shellenv)
fish_add_path $brew_dir/bin
fish_add_path $brew_dir/sbin
fish_add_path $brew_dir/opt/llvm/bin
fish_add_path $brew_dir/opt/openjdk/bin
