status is-interactive || exit

# build runners
type -q just; and alias ju just
type -q mask; and alias mk mask

# replace nodejs stuff with bun
if type -q bun
    alias node bun
    alias npm bun
    alias npx bunx
end

# interactive json/yaml preview
if type -q fx
    set -gx FX_THEME '3'
    alias json fx
    alias yaml "fx --yaml"
end

# colorized tail
type -q tspin; and alias tail tspin

# better 'loc'
type -q tokei; and alias loc tokei

# colored markdown preview
type -q glow; and alias md "glow -s dracula -p -t"

# create slidev presentations
alias slidev_create "npm create slidev"

# create animated code presentation project
alias animotion_create "npm create @animotion@latest"

# interactive logs viewer
if type -q gonzo
    gonzo completion fish | source
    alias logs gonzo
    function readlogs -d "interactive logs viewer" -a files
        if count $files > 0
            set -l args
            for file in $files
                if string match -q "-*" -- $file
                    set -a args $file
                else
                    set -a args -f $file
                end
            end
            gonzo $args
        else
            gonzo
        end
    end
end
