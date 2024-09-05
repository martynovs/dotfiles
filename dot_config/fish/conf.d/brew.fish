status is-interactive && type -q brew || exit

abbr -a br brew

alias bri '__fzf_brew install'
alias bro '__fzf_brew info'
alias brm '__fzf_brew uninstall'
abbr -a brl 'brew list'
abbr -a brs 'brew search'
abbr -a bru 'brew upgrade'

alias bci '__fzf_brew_cask install'
alias bco '__fzf_brew_cask info'
alias bcm '__fzf_brew_cask uninstall'
abbr -a bcl "brew list --cask"
abbr -a bcu 'brew upgrade --cask'

function _fzf_search_brew_installed
    set -f query (commandline --current-token)
    set -f selected (brew leaves | _fzf_wrapper --ansi --query $query --preview="HOMEBREW_COLOR=true brew info {1}" \
        --prompt="Select brew package> "                              --preview-window="right:60%:wrap"
    )
    test -n "$selected" && commandline --current-token --replace -- $selected
    commandline --function repaint
end

function _fzf_search_brew_global
    set -f query (commandline --current-token)
    set -f selected (brew formulae | _fzf_wrapper --ansi --query $query --preview="HOMEBREW_COLOR=true brew info {1}" \
        --prompt="Search brew packages> "                               --preview-window="right:60%:wrap"
    )
    test -n "$selected" && commandline --current-token --replace -- $selected
    commandline --function repaint
end

function __fzf_brew --description 'Fuzzy-find and run a Homebrew command on a formula' --argument-names cmd
    switch $cmd
        case upgrade uninstall remove rm
            set -f source_cmd "brew leaves"
        case '*'
            set -f source_cmd "brew formulae"
    end
    set -f selected (eval $source_cmd | _fzf_wrapper --ansi --preview="HOMEBREW_COLOR=true brew info {1}" \
        --prompt="brew $cmd> "                              --preview-window="right:60%:wrap"
    )
    test -n "$selected" && commandline --current-token --replace -- "brew $cmd $selected"
    commandline --function repaint
end

function __fzf_brew_cask --description 'Fuzzy-find and run a Homebrew command on a cask' --argument-names cmd
    switch $cmd
        case upgrade uninstall remove rm
            set -f source_cmd "brew list --cask"
        case '*'
            set -f source_cmd "brew casks"
    end
    set -f selected (eval $source_cmd | _fzf_wrapper --ansi --preview="HOMEBREW_COLOR=true brew info --cask {1}" \
        --prompt="brew --cask $cmd> "                       --preview-window="right:60%:wrap"
    )
    test -n "$selected" && commandline --current-token --replace -- "brew $cmd --cask $selected"
    commandline --function repaint
end
