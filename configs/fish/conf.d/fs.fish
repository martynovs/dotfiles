status is-interactive || exit

# useful shortcuts
abbr -a -- - "cd -"
abbr -a -- +x "chmod +x"
abbr -a my "chown -R \$(whoami)"
abbr -a rf "rm -rf"

# nice ls
if type -q eza
    alias l "eza"
    alias ll "eza -lag"
end

# smart cd
if type -q zoxide
    zoxide init fish --no-cmd | source
    # go to dir from history
    bind ctrl-q "__zoxide_zi; commandline -f repaint"
    alias cd __zoxide_z
    set -gx _ZO_FZF_OPTS
end

# interactive du
type -q gdu-go; and alias du "gdu-go"

# nice df
type -q duf; and alias df duf
