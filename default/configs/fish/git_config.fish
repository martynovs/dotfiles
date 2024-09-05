if status is-interactive

    if type -q git
        function git-cd-root -d 'cd to root dir of current git repo'
            cd (git rev-parse --show-toplevel)
            commandline -f repaint
        end
        bind \e\[H git-cd-root # home button
        bind \a git-cd-root # ctrl + g

        abbr -a g git
    end

    type -q scalar; and alias clone="scalar clone"
    type -q lazygit; and alias gg="lazygit -ucd $HOME/.config/lazygit"

    type -q jj; and jj util completion fish | source
    type -q jj; and abbr -a j "jj"
    type -q lazyjj; and alias jjj="lazyjj"

end
