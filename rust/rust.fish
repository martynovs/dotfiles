if status is-interactive

    function rman -d "man for Rust symbols"
        set -l symbol (string join " " $argv)
        rusty-man $symbol | bat -p -l man -l rust
    end

end
