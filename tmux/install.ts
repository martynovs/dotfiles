#!/usr/bin/env -S node --experimental-strip-types

import { brew, printScript } from '../helpers.ts';

printScript(
  brew('tmux'), // terminal multiplexer (tabs within terminal)
  brew('tpm'),  // tmux plugin manager
  brew('sesh').go_pkg('joshmedeski/sesh'), // tmux session manager
)
