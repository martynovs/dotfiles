#!/usr/bin/env -S node --experimental-strip-types

import { brew, native, printScript } from '../helpers.ts';

printScript(
  // shell
  brew('fish'),
  brew('fisher'),
  brew('starship'),
  native('direnv'),

  // editor
  brew('helix'),
  brew('yazi'),

  // basic cli
  native('fzf'),
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
