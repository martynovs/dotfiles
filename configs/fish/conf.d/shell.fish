# remove greeting
set -g fish_greeting

status is-interactive || exit

# fix ghostty TERM
[ "$TERM" = "xterm-ghostty" ]; and set -gx TERM "xterm-256color"

# nice prompt
if type -q starship
    function starship_transient_prompt_func
        starship module character
    end
    function starship_transient_rprompt_func
        starship module time
    end
    starship init fish | source
    enable_transience
end

# show exit code if command failed with error
function print_exit_error_code --on-event fish_postexec
    set -l code $status
    if test $code -ne 0
        set -l red (set_color --bold red)
        set -l norm (set_color normal)
        echo "Exit code: $red$code$norm"
    end
end    

# smart find
if type -q fzf
    set -gx fzf_preview_dir_cmd "eza -l --no-user --color=always --icons=always"
    set -gx fzf_preview_file_cmd "bat -p --color=always --theme='OneHalfDark' --line-range :500"
    bind ctrl-f "_fzf_search_directory"
    bind ctrl-r "_fzf_search_history"
    bind ctrl-v "$_fzf_search_vars_command"
    bind ctrl-] "_fzf_search_processes"
end

# colored 'cat', 'man' and help
if type -q bat
    alias cat "bat -p"
    set -g HELP_LESS "bat -p -l help"
    set -gx MANPAGER "sh -c 'col -bx | bat -p -l man'"

    type -q batman; and alias man batman
    type -q batpipe; and batpipe | source
end
