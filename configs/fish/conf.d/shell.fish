# remove greeting
set -g fish_greeting

status is-interactive || exit

# load direnv only for interactive shell
if command -q direnv
    direnv hook fish | source
    set -g direnv_fish_mode eval_on_arrow
end

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

# press '?' to show help for command in commandline
bind \? 'test -z "$HELP_LESS"; and set -l HELP_LESS "less -R"; \
         set -l cmd (commandline --cut-at-cursor); \
         test -n "$cmd"; and eval "$cmd --help | $HELP_LESS"; \
         commandline -f repaint'

# switch from shell to background task (works with hx/nvim/tmux)
bind ctrl-z "fg 2>/dev/null; commandline -f repaint"

# editor
type -q code; and abbr -a c. "code ."; and set -gx EDITOR code
type -q nvim; and alias v nvim; and set -gx EDITOR nvim
type -q hx;   and alias e hx;   and set -gx EDITOR hx

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

# better top
type -q btop; and alias top btop

# nice system info
type -q fastfetch; and alias i fastfetch

if type -q brew
    abbr -a br brew
    abbr -a bri "brew install"
    abbr -a bro "brew info"
    abbr -a brs "brew search"
    type -q taproom; and alias bb taproom
end
