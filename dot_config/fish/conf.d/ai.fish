status is-interactive || exit

alias mcp 'npx @modelcontextprotocol/inspector'

alias cl  'px claude'
alias clc 'px claude -c'
alias clw 'px npx cc-wiretap'

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

type -q sidecar && alias sc sidecar
type -q gastown && alias gas gastown

# alias beads bd # already renamed to bd

alias tm          'npx -p task-master-ai task-master'
alias task-master 'npx -p task-master-ai task-master'

alias bmad 'npx bmad-method'

alias speckit 'uvx --from git+https://github.com/github/spec-kit.git specify'

alias openspec      'npx @fission-ai/openspec@latest'
alias openspec-init 'npx @fission-ai/openspec@latest init --tools opencode,github-copilot'

if type -q claude
  function _claude_translate -d "translate natural language to shell command and replace commandline"
    set -x HTTP_PROXY $LOCAL_PROXY
    set -x HTTPS_PROXY $LOCAL_PROXY
    set -l input (string join ' ' $argv)
    test -z "$input" && return
    set -l os (uname -sr)
    set -l prompt "Translate the user's description into a shell command. Output only the command on a single line — no explanation, no quotes, no markdown. OS: $os, shell: fish."
    set -l cmd (echo "$input" | gum spin --title "Thinking..." -- claude -p --system-prompt "\"$prompt\"")
    commandline -r "$cmd "
    commandline -f repaint
  end

  function s -d "translate natural language to shell command"
    _claude_translate (string join ' ' $argv)
  end

  function _s_keybind
    _claude_translate (commandline)
  end

  bind ctrl-s _s_keybind
end

function cll -d "run claude with local AI (interactive model selection)"
  type -q claude; or begin; echo "cll: claude is not installed or not found in PATH"; return 1; end
  type -q gum;    or begin; echo "cll: gum is required but not found in PATH";        return 1; end
  type -q jq;     or begin; echo "cll: jq is required but not found in PATH";         return 1; end
  test -n "$LOCAL_AI_API_URL"; or begin; echo "cll: LOCAL_AI_API_URL is not set";     return 1; end

  set -l base_url $LOCAL_AI_API_URL
  set -l models_json (curl -sf "$base_url/api/v1/models"); or begin;
    echo "cll: failed to fetch models from $base_url"; return 1; 
  end

  set -l keys        (echo $models_json | jq -r '.models[] | select(.type == "llm") | .key')
  set -l names       (echo $models_json | jq -r '.models[] | select(.type == "llm") | .display_name')
  set -l loaded      (echo $models_json | jq -r '.models[] | select(.type == "llm") | (.loaded_instances | length) > 0')
  set -l loaded_key  (echo $models_json | jq -r 'first(.models[] | select(.type == "llm" and (.loaded_instances | length) > 0) | .key) // ""')
  set -l instance_id (echo $models_json | jq -r 'first(.models[] | select(.type == "llm" and (.loaded_instances | length) > 0) | .loaded_instances[0].id) // ""')

  set -l preselect ""
  for i in (seq (count $keys))
    if test $loaded[$i] = true
      set preselect $names[$i]
      break
    end
  end

  set -l chosen (gum choose --selected="$preselect" --header="Local AI model:" $names)
  test -z "$chosen" && return 0

  set -l model ""
  for i in (seq (count $names))
    if test "$names[$i]" = "$chosen"
      set model $keys[$i]
      break
    end
  end

  if test "$model" != "$loaded_key"
    if test -n "$loaded_key"
      gum spin --title "Unloading $loaded_key..." -- \
        curl -sf -X POST "$base_url/api/v1/models/unload" \
          -H "Content-Type: application/json" \
          -d "{\"instance_id\": \"$instance_id\"}"
    end
    gum spin --show-output --title "Loading $model..." -- \
      curl -sf -X POST "$base_url/api/v1/models/load" \
        -H "Content-Type: application/json" \
        -d "{\"model\": \"$model\", \"context_length\": 131072, \"flash_attention\": true, \"offload_kv_cache_to_gpu\": true, \"echo_load_config\": true}"
  end

  ANTHROPIC_BASE_URL="$base_url" claude --model "$model" $argv
end
