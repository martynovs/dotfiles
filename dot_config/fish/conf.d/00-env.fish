set -gx XDG_CONFIG_HOME ~/.config
set -gx XDG_CACHE_HOME ~/.cache

set -gx GOPATH ~/.go
fish_add_path ~/.go/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin
fish_add_path ~/.dotnet/tools
fish_add_path ~/.cache/.bun/bin

fish_add_path node_modules/.bin
fish_add_path .venv/bin

# add Homebrew env
set -a dirs "/home/linuxbrew/.linuxbrew"
set -a dirs "/opt/homebrew"
for dir in $dirs
    if [ -x $dir/bin/brew ]
        eval ($dir/bin/brew shellenv)
        fish_add_path $dir/bin
        fish_add_path $dir/sbin
        fish_add_path $dir/opt/llvm/bin
        fish_add_path $dir/opt/openjdk/bin
    end
end
set -e dirs
