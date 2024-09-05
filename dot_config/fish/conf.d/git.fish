status is-interactive || exit

alias g   git
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

function git-cd-root -d 'cd to root dir of current git repo'
    set -l root (git rev-parse --show-toplevel)
    test $status -eq 0; and cd $root; commandline -f repaint
end

alias ji jjui

function jj-cd-root -d 'cd to root dir of current jj repo'
    set -l root (jj root)
    test $status -eq 0; and cd $root; commandline -f repaint
end
