function __fish_brew_home -d "Home directory of brew installation"
    set -a dirs "/home/linuxbrew/.linuxbrew"
    set -a dirs "/opt/homebrew"
    for dir in $dirs
        if [ -x $dir/bin/brew ]
            echo $dir
            return 0;
        end
    end
end
