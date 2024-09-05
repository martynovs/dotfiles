#!/bin/bash

dir=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")
# shellcheck source=installers/_helpers.sh
source "$dir/_helpers.sh"

header "Configuring dotnet lsp"
run "dotnet tool install -g csharp-ls"
