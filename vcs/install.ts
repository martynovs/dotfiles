#!/usr/bin/env -S node --experimental-strip-types

import { brew, go_pkg, linux, macos, native, printScript } from '../helpers.ts';

printScript(
  native('gh'),
  brew('git'),
  brew('gitui'),
  macos('lazygit'),
  linux(go_pkg('jesseduffield/lazygit')),
  brew('git-delta'), // colored git diff
  brew('jj'),
  macos('jjui'),
  linux(go_pkg('idursun/jjui/cmd/jjui')),
)
