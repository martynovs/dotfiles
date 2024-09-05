status is-interactive || exit

# task runner
if type -q just
    alias j   just
    alias jl  "just --list"
    alias jd  "just down"
    alias jb  "just build"
    alias jt  "just test"
    alias jty "just typecheck"
    alias ji  "just install"
end

# replace nodejs stuff with bun
if type -q bun
    alias node bun
    alias npx bunx
    alias npm "bunx npm"
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
type -q glow; and alias md "glow -s tokyo-night -p"

# create slidev presentations
alias slidev_create "npm create slidev"

# create animated code presentation project
alias animotion_create "npm create @animotion@latest"

function vscode_clean_recent -d "Remove non-existent folders and files from VSCode recent projects"
    set -l db "$HOME/Library/Application Support/Code/User/globalStorage/state.vscdb"
    if not test -f $db
        echo "VSCode state database not found: $db"
        return 1
    end

    set -l json (sqlite3 "$db" "SELECT value FROM ItemTable WHERE key = 'history.recentlyOpenedPathsList'")
    if test -z "$json"
        echo "No recent projects found."
        return 0
    end

    # echo $json | jq '.entries[]'

    set -l total (echo $json | jq '.entries | length')
    set -l keep
    set -l removed 0

    for i in (seq 0 (math "$total - 1"))
        set -l entry (echo $json | jq -c ".entries[$i]")

        if echo $entry | jq -e '.folderUri' > /dev/null 2>&1
            set -l path (echo $entry | jq -r '.folderUri' | string replace 'file://' '' | string replace -a '%20' ' ')
            if test -d $path
                set -a keep $i
            else
                echo "Removing: $path"
                set removed (math "$removed + 1")
            end
        else if echo $entry | jq -e '.workspace.configPath' > /dev/null 2>&1
            set -l path (echo $entry | jq -r '.workspace.configPath' | string replace 'file://' '' | string replace -a '%20' ' ')
            if test -f $path
                set -a keep $i
            else
                echo "Removing workspace: $path"
                set removed (math "$removed + 1")
            end
        else
            set -l path (echo $entry | jq -r '.fileUri // "unknown"' | string replace 'file://' '')
            echo "Removing file: $path"
            set removed (math "$removed + 1")
        end
    end

    if test $removed -eq 0
        echo "Nothing to remove."
        return 0
    end

    set -l keep_json (printf '%s\n' $keep | jq -s '.')
    set -l new_json (echo $json | jq --argjson k "$keep_json" '.entries = [.entries[$k[]]]')
    sqlite3 "$db" "UPDATE ItemTable SET value = '$(string replace -a "'" "''" -- $new_json)' WHERE key = 'history.recentlyOpenedPathsList'"
    echo "Done. Kept "(count $keep)", removed $removed."
end

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
