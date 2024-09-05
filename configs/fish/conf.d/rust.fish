status is-interactive || exit

type -q rusty-man; and alias rman rusty-man

function carr -d "run cargo target, select one if empty" -a target
    if test -z "$target"
        cargo-selector selector -i
    else
        cargo run $argv
    end
end 
