status is-interactive || exit

alias g   git
alias gu  gitui
alias gg  "lazygit -ucd $HOME/.config/lazygit"    
alias gw  'git worktree'
alias gs  'git status'
alias gl  'git l'
alias gb  'git branch'
alias gt  'git tag'

type -q branchlet; and alias gw 'branchlet'

function git-cd-root -d 'cd to root dir of current git repo'
    set -l root (git rev-parse --show-toplevel)
    test $status -eq 0; and cd $root; commandline -f repaint
end

alias j jjui

function jj-cd-root -d 'cd to root dir of current jj repo'
    set -l root (jj root)
    test $status -eq 0; and cd $root; commandline -f repaint
end
