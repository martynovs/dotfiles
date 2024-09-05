# load/unload .envrc files when changing directory
if command -q direnv
    direnv hook fish | source
    set -g direnv_fish_mode eval_on_arrow
end
