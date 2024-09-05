
# Run shellcheck on all shell scripts
shellcheck:
    shellcheck -x $(git ls-files | grep -v "\.tmpl$" | xargs grep -l "^#!.*bin/bash")
