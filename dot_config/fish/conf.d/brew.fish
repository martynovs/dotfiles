status is-interactive && type -q brew || exit

abbr -a br brew

alias bri '__fzf_brew install'
abbr -a brl 'brew list'
abbr -a bro 'brew info'
abbr -a brs 'brew search'
abbr -a bru 'brew upgrade'
abbr -a brm 'brew uninstall'

alias cri '__fzf_brew_cask install'
abbr -a crl "brew list --cask"
abbr -a cro 'brew info --cask'
abbr -a cru 'brew upgrade --cask'
abbr -a crm 'brew uninstall --cask'

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

function brew_tap_cleanup --description 'For each tap, select formulas to uninstall; if none installed, offer to remove tap'
    set -f all_installed (brew list --formula)

    for tap in (brew tap)
        set -f tap_all (brew tap-info --json=v1 $tap 2>/dev/null | jq -r '.[0].formula_names[]' 2>/dev/null | string replace "$tap/" "")

        set -f tap_formulas
        for f in $all_installed
            if contains $f $tap_all
                set -a tap_formulas $f
            end
        end

        if test (count $tap_formulas) -eq 0
            echo "Tap '$tap' has no installed formulas."
            echo "Available formulas:"
            printf "  %s\n" $tap_all
            gum confirm "Remove tap '$tap'?"
            set -f s $status
            test $s -eq 130 && return 1
            test $s -eq 0 && brew untap $tap
        else
            set -f to_remove (gum choose --no-limit --header "Tap: $tap — select formulas to uninstall:" $tap_formulas)
            test $status -eq 130 && return 1
            for f in $to_remove
                brew uninstall $f
            end
            if test (count $to_remove) -eq (count $tap_formulas)
                gum confirm "All formulas removed. Remove tap '$tap'?"
                set -f s $status
                test $s -eq 130 && return 1
                test $s -eq 0 && brew untap $tap
            end
        end
    end
end
