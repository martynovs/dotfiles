#!/usr/bin/env -S node --experimental-strip-types

import { brew, go_pkg, linux, macos, printScript } from '../helpers.ts';

printScript(
  brew('tmux'),
  brew('tpm'),
  macos('sesh'),
  linux(go_pkg('joshmedeski/sesh')),
)
