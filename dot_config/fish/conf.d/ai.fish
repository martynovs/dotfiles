status is-interactive || exit

alias cl  'px claude'
alias clc 'px claude -c'

alias op  'px opencode'
alias opc 'px opencode -c'

alias sk     'npx skills'
alias skills 'npx skills'

if type -q backlog
  alias bl backlog
  alias bb 'backlog board'
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

if type -q claude
  function s -d "translate natural language to shell command" -a input
    set -l input (string join ' ' $argv)
    set -l prompt "you help me to type in terminal, i give you text description of what terminal command should do and you give me shell command in one line and nothing more, output just single line of text with terminal command, no quotes"
    set -l cmd (echo "$input" | claude -p --system-prompt "\"$prompt\"")
    commandline -r "$cmd "
    commandline -f repaint
  end
end
