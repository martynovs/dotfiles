# remove greeting
set -g fish_greeting

# add Homebrew env
set -a brew_dirs "/home/linuxbrew/.linuxbrew"
set -a brew_dirs "/opt/homebrew"
for brew_dir in $brew_dirs
    if [ -x $brew_dir/bin/brew ]
        eval ($brew_dir/bin/brew shellenv)
        fish_add_path $brew_dir/bin
        fish_add_path $brew_dir/sbin
        fish_add_path $brew_dir/opt/llvm/bin
    end
end
