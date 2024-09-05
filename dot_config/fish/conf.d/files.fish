status is-interactive || exit

# nice shortcuts
abbr -a -- - "cd -"
abbr -a -- +x "chmod +x"
abbr -a my "chown -R \$(whoami)"
abbr -a rf "rm -rf"
abbr -a w "command -v"

# nice file manager
type -q nnn; and alias n "nnn"

# nice ls
type -q eza; and alias l "eza"; and alias ll "eza -lag"

# nice dir tree
if type -q eza; and type -q bat
    function t -d "Show directory tree short info"
        eza --tree --color=always --git --git-ignore $argv | bat -p
    end
    function tt -d "Show directory tree detailed info"
        eza --tree --color=always --git --git-ignore -ol --smart-group --total-size $argv | bat -p
    end
    function ttt -d "Show directory tree detailed info including hidden dirs and files"
        eza --tree --color=always --git --git-ignore -ol --smart-group --total-size -a -I '.git|.jj' $argv | bat -p
    end
end

# interactive du
type -q gdu-go; and alias du "gdu-go"

# nice df
type -q duf; and alias df duf

# smart cd
if type -q zoxide
    zoxide init fish --no-cmd | source
    # find dir from history (seeded with current token): cd on empty line,
    # else replace the current token with the picked path.
    # Use zoxide's own interactive fzf (keeps its look) with no keyword so it
    # lists everything, and inject the token as fzf --query; zoxide searches
    # --nth=2 (the path field), so intermediate segments (.worktrees) match.
    function _zoxide_pick -d "zoxide interactive: cd if line empty, else replace token"
        set -l token (commandline -t)
        set -lx _ZO_FZF_OPTS $_ZO_FZF_OPTS --query=$token
        set -l dir (command zoxide query --interactive 2>/dev/null)
        if test -n "$dir"
            if test -z (string trim -- (commandline))
                __zoxide_cd $dir
            else
                commandline -rt -- (string escape -- $dir)
            end
        end
        commandline -f repaint
    end
    bind ctrl-q _zoxide_pick
    alias cd __zoxide_z
    set -gx _ZO_FZF_OPTS
end

# file explorer
if type -q yazi
    function z -d "Go to directory from yazi"
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
end
