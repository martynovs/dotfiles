# remove greeting
set -g fish_greeting

# add Homebrew env
set brew_dir (__fish_brew_home)
eval ($brew_dir/bin/brew shellenv)
fish_add_path $brew_dir/bin
fish_add_path $brew_dir/sbin
fish_add_path $brew_dir/opt/llvm/bin
