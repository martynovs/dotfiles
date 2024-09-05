if status is-interactive

    if type -q git
        function git-cd-root -d 'cd to root dir of current git repo'
            cd (git rev-parse --show-toplevel)
            commandline -f repaint
        end
        bind \e\[H git-cd-root # home button
        bind \a git-cd-root # ctrl + g

        abbr -a g git
        abbr -a ga "git add ."
        abbr -a gs "git status"
        abbr -a gd "git diff"
        abbr -a gc "git checkout"
        abbr -a gb "git branch"
        abbr -a gl "git lg"
        abbr -a gp "git push"
        abbr -a gw "git worktree"
        abbr -a gsw "git switch"
        abbr -a gre "git restore"
    end

    type -q scalar; and alias clone="scalar clone"
    type -q lazygit; and alias gg="lazygit -ucd $HOME/.config/lazygit"
    type -q git-branchless; and alias ggg="git-branchless"

    type -q gitu;  and abbr -a gu gitu
    type -q gitup; and abbr -a gu gitup

    if type -q jj
        jj util completion fish | source
        abbr -a j jj
        abbr -a jjn "jj new"
        abbr -a jjs "jj status"
        abbr -a jjq "jj squash"
    end

end
