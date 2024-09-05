#!/bin/bash

dir=$(dirname -- "$(readlink -f "${BASH_SOURCE}")")
source $dir/_helpers.sh

header "Configuring dotnet lsp"
run "dotnet tool install -g csharp-ls"
