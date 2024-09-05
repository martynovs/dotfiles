# Tasks

## shellcheck

> Run shellcheck on all shell scripts

~~~sh
shellcheck -x $(git ls-files | grep -v "\.tmpl$" | xargs grep -l "^#!.*bin/bash")
~~~
