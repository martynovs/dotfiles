status is-interactive || exit

alias g    git
alias ge  'sl web'
alias gg  "lazygit -ucd $HOME/.config/lazygit"    
alias gp  'git pull'
alias gpf 'git pull -f'
alias gf  'git fetch --all --prune'
alias gr  'git rebase -i'
alias gw  'git worktree'
alias gc  'git checkout'
alias gcp 'git cherry-pick'
alias gs  'git status'
alias gl  'git l'
alias gb  'git branch'
alias gt  'git tag'
alias gu  'git who'

# Gitlab helpers

function mr_id -d 'resolve MR id from issue number or search query'
    set -l first $argv[1]
    if string match -qr '^!\d+$' -- "$first"
        string replace '!' '' -- "$first"
    else if string match -qr '^\d+$' -- "$first"
        set -l mr_id (glab mr list --output json | jq -r --arg iid $first '.[] | select(.title | test("(^|: )" + $iid + ":")) | .iid' | head -1)
        if test -z "$mr_id"
            echo "No MR found for issue #$first" >&2
            return 1
        end
        echo $mr_id
    else if test -n "$argv"
        set -l items (glab mr list --search "$argv" --output json | jq -r '.[] | "!\(.iid) \(.title)"')
        test -z "$items"; and return 1
        set -l selected (printf '%s\n' $items | gum choose)
        test -z "$selected"; and return 1
        string replace -r '^!(\d+).*' '$1' $selected
    else
        return 1
    end
end

function mr_select -d 'select one of my MR'
    set -l items (glab mr list --assignee @me --output json | jq -r '.[] | "!\(.iid) \(.title)"')
    test -z "$items"; and return 1
    set -l selected (printf '%s\n' $items | gum choose)
    test -z "$selected"; and return 1
    string replace -r '^!(\d+).*' '$1' $selected
end

function _mr_rename_tmux_window -d 'rename tmux window for current MR worktree' -a mr_id win_id
    set -l iid (git rev-parse --abbrev-ref HEAD | string match -r '^\d+')
    set -l window_name "#[fg=colour99]!$mr_id"
    test -n "$iid"; and set window_name "##$iid#[fg=colour99]!$mr_id"
    set -l others (tmux list-windows -F '#{window_id}:#{window_name}' | grep -E "!$mr_id\$" | grep -v "^$win_id:")
    tmux rename-window -t $win_id $window_name
    for entry in $others
        set -l parts (string split -m1 : $entry)
        tmux rename-window -t $parts[1] $parts[2]
    end
end

# Worktrees (wt)

function ww -d 'cd to main repo dir from any worktree'
    set -l win_id (tmux display-message -p '#{window_id}')
    cd (git worktree list --porcelain | head -1 | string replace 'worktree ' '')
    and tmux set-window-option -t $win_id automatic-rename on
end

function we -d 'switch worktree'
    set -l win_id (tmux display-message -p '#{window_id}')
    wt switch $argv; or return 1
    set -l mr_id (glab mr view --output json 2>/dev/null | jq -r '.iid // empty')
    test -n "$mr_id"; and _mr_rename_tmux_window $mr_id $win_id
end

function wr -d 'switch worktree to MR by number or search text'
    set -l win_id (tmux display-message -p '#{window_id}')
    set -l mr_id (if test -n "$argv"; mr_id $argv; else; mr_select; end)
    or return 1
    wt switch mr:$mr_id; or return 1
    _mr_rename_tmux_window $mr_id $win_id
end

function wrc -d 'switch worktree to MR and open claude'
    wr $argv
    and claude
    and wd
end

function wd -d 'remove worktree'
    set -l win_id (tmux display-message -p '#{window_id}')
    wt remove --foreground --no-delete-branch $argv
    tmux set-window-option -t $win_id automatic-rename on
end

function wdd -d 'remove worktree and delete branch'
    set -l win_id (tmux display-message -p '#{window_id}')
    set -l branch (git rev-parse --abbrev-ref HEAD)
    wt remove --foreground -D $branch $argv
    tmux set-window-option -t $win_id automatic-rename on
end
