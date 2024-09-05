#!/bin/bash

dir=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")
# shellcheck source=installers/_helpers.sh
source "$dir/_helpers.sh"


header "Configuring yazi"
run "ya pkg add bennyyip/gruvbox-dark || echo -n"
run "ya pkg add yazi-rs/plugins:smart-enter || echo -n"


header "Configuring fish shell"
shell=$(command -v fish || echo 'none')
if [[ "$shell" == "none" ]]; then
  run "brew install fish || true"
  run "brew unlink fish && brew link fish"
  shell=$(command -v fish)
fi

if ! grep -q "$shell" /etc/shells; then
  run "echo \"$shell\" | $(sudo_prefix)tee -a /etc/shells"
fi

if [[ "$SHELL" != "$shell" ]]; then
  if sudo -n true 2>/dev/null; then
    run "sudo chsh -s $shell $(whoami)"
  else
    run "chsh -s $shell"
  fi
fi

header "Install fish plugins"
if [ -t 0 ]; then
  # this works only in interactive mode
  run "fish -c 'fisher update > /dev/null'"
else
  echo "Please manually install fish plugins before running fish shell"
  echo "If you are using bash first reload your current shell config with:"
  echo "source ~/.bashrc"
  echo "Then install fish plugins with:"
  echo "fish -c 'fisher update'"
  echo "After installation of plugins you can run: fish"
fi
