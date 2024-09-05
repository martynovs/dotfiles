status is-interactive || exit

alias gm 'gemini'

alias op 'proxychains4 -q -f ~/.config/proxy opencode'

alias bmad 'npx bmad-method'

alias speckit 'uvx --from git+https://github.com/github/spec-kit.git specify'

alias openspec 'npx @fission-ai/openspec@latest'

if type -q q
    # ctrl-s to translate natural language to shell command
    bind ctrl-s 'test -z (commandline); and q translate; or s (commandline)'

    function s -d "translate natural language to shell command" -a input
        set -l tmpfile (mktemp)
        set -l input (string join ' ' $argv)
        eval echo "$input" | q translate > $tmpfile &
        set -l bg_pid $last_pid
        set -l spin_chars (string split '' '⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏')
        set -l count (count $spin_chars)
        set -l i 1
        while kill -0 $bg_pid >/dev/null 2>&1
            printf "\r\033[1C%s" $spin_chars[$i] >&2
            sleep 0.1
            set i (math "($i % $count) + 1")
        end
        printf "\r\033[1C " >&2  # Clear the line
        wait $bg_pid
        set -l cmd (cat $tmpfile)
        rm $tmpfile
        commandline -r "$cmd "
        commandline -f repaint
    end
end
