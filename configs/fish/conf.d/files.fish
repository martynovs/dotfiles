status is-interactive || exit

# nice shortcuts
abbr -a -- - "cd -"
abbr -a -- +x "chmod +x"
abbr -a my "chown -R \$(whoami)"
abbr -a rf "rm -rf"
abbr -a w "command -v"

# nice ls
type -q eza; and alias l "eza"; and alias ll "eza -lag"

# nice dir tree
type -q eza; and type -q bat; and alias t "eza --tree --color=always | bat -p"

# interactive du
type -q gdu-go; and alias du "gdu-go"

# nice df
type -q duf; and alias df duf

# smart cd
if type -q zoxide
    zoxide init fish --no-cmd | source
    # find and cd to dir from history
    bind ctrl-q "__zoxide_zi; commandline -f repaint"
    alias cd __zoxide_z
    set -gx _ZO_FZF_OPTS
end

# file explorer
if type -q yazi
    function c -d "Go to directory from yazi"
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
end

type -q spf; and alias f spf # superfile
