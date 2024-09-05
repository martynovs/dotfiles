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
    bind ctrl-f "_fzf_search_directory"
    bind ctrl-r "_fzf_search_history"
    bind ctrl-v "_fzf_search_variables"
    bind ctrl-] "_fzf_search_processes"
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
