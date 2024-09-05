#!/usr/bin/env -S node --experimental-strip-types

import { brew, universal, printScript } from '../helpers.ts';

printScript(
  universal('gh'),
  brew('git'),
  brew('lazygit').go_pkg('jesseduffield/lazygit'), // git tui
  brew('git-delta'), // colored git diff
  brew('jj'),   // modern git alternative
  brew('jjui'), // jj terminal ui
)
