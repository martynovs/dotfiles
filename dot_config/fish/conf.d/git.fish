status is-interactive || exit

alias g    git
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

alias gil 'px glab issue list'
alias giy 'px glab issue list --assignee "@me"'
alias gi  'px glab issue view'

alias gml 'px glab mr list'
alias gmy 'px glab mr list --assignee "@me"'
alias gm  'px glab mr checkout'

function git-cd-root -d 'cd to root dir of current git repo'
    set -l root (git rev-parse --show-toplevel)
    test $status -eq 0; and cd $root; commandline -f repaint
end

# Worktree (wt)

alias we 'wt switch'
alias wc 'wt step commit'
alias wd 'wt remove --no-delete-branch --foreground'

function wr -d 'switch worktree to MR by number or search text'
    if string match -qr '^\d+$' -- "$argv[1]"
        wt switch mr:$argv[1]
    else
        set selected (px glab mr list --search "$argv[1]" --output json | jq -r '.[] | "!\(.iid) \(.title)"' | gum choose)
        test -z "$selected"; and return 0
        set mr_id (string replace -r '^!(\d+).*' '$1' $selected)
        wt switch mr:$mr_id
    end
end

alias ji jjui

function jj-cd-root -d 'cd to root dir of current jj repo'
    set -l root (jj root)
    test $status -eq 0; and cd $root; commandline -f repaint
end
