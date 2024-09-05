status is-interactive || exit

# nice shortcuts
abbr -a -- - "cd -"
abbr -a -- +x "chmod +x"
abbr -a my "chown -R \$(whoami)"
abbr -a rf "rm -rf"


# smart cd
if type -q zoxide
    zoxide init fish --no-cmd | source
    # find and cd to dir from history
    bind ctrl-q "__zoxide_zi; commandline -f repaint"
    alias cd __zoxide_z
    set -gx _ZO_FZF_OPTS
end

# smart find
if type -q fzf
    set -gx fzf_preview_dir_cmd "eza -l --no-user --color=always --icons=always"
    set -gx fzf_preview_file_cmd "bat -p --color=always --theme='OneHalfDark' --line-range :500"
    fzf_configure_bindings \
        --history='ctrl-r' \
        --directory='ctrl-f,ctrl-d' \
        --processes='ctrl-f,ctrl-a' \
        --variables='ctrl-f,ctrl-e' \
        --git_status='ctrl-f,ctrl-g' \
        --git_log='ctrl-f,ctrl-s'
end

# file explorer
if type -q yazi
    function f -d "Open directory in yazi"
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
end
