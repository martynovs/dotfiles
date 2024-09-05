status is-interactive || exit

alias cl  'px claude'

alias op  'px opencode'
alias ops "px opencode -s $(opencode session list | awk 'NR==3 {print $1}')"

alias sk     'npx skills'
alias skills 'npx skills'

if type -q backlog
    alias bl      'backlog'
    alias bb      'backlog board'
else
    alias bl      'npx backlog.md'
    alias bb      'npx backlog.md board'
    alias backlog 'npx backlog.md'
end

alias beads bd

alias tm          'npx -p task-master-ai task-master'
alias task-master 'npx -p task-master-ai task-master'

alias bmad     'npx bmad-method'
alias bmad-pre 'npx bmad-method@alpha'

alias speckit 'uvx --from git+https://github.com/github/spec-kit.git specify'

alias openspec      'npx @fission-ai/openspec@latest'
alias openspec-init 'npx @fission-ai/openspec@latest init --tools opencode,github-copilot'

alias mcp 'npx @modelcontextprotocol/inspector'

if type -q kiro-cli
    alias kiro 'kiro-cli'
    # ctrl-s to translate natural language to shell command
    bind ctrl-s 'test -z (commandline); and kiro-cli translate; or s (commandline)'

    function s -d "translate natural language to shell command" -a input
        set -l tmpfile (mktemp)
        set -l input (string join ' ' $argv)
        eval echo "$input" | kiro-cli translate > $tmpfile 2> $tmpfile.err &
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
        set -l err (cat $tmpfile.err)
        rm $tmpfile
        rm $tmpfile.err
        if test -n "$cmd"
            commandline -r "$cmd "
        else
            echo $err
            echo
            echo
            commandline -r "$input"
        end
        commandline -f repaint
    end
end
