#!/usr/bin/env -S node --experimental-strip-types

import { brew, printScript } from '../helpers.ts';

printScript(
  // shell
  brew('fish'),
  brew('fisher'),
  brew('starship'),

  // editor
  brew('helix'),
  brew('yazi'),

  // basic cli
  brew('fzf').sans_arm(),
  brew('zoxide'),     // cd with history
  brew('eza'),        // ls with colors
  brew('bat'),        // cat with colors
  brew('bat-extras'), // batman and more
  brew('sd'),         // sed/awk for mere mortals
  brew('fd'),         // find
  brew('ripgrep'),    // grep
  brew('thefuck'),    // fix your last command
  brew('fastfetch'),  // system information
  brew('xh'),         // http client
)
