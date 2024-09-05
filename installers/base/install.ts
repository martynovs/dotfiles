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
  brew('gum').sans_arm(), // helpers for nice shell scripts
  brew('zoxide'),     // cd with history
  brew('eza'),        // ls with colors
  brew('bat'),        // cat with colors
  brew('bat-extras'), // batman and more
  brew('sd'),         // sed/awk for mere mortals
  brew('fd'),         // find
  brew('ripgrep'),    // grep
  brew('thefuck'),    // fix your last command
  brew('xh'),         // http client

  // basic system monitoring
  brew('fastfetch'),  // system information
  brew('btop'),       // system monitor
  brew('bottom'),     // system monitor with temperature info
  brew('duf'),        // df with colors
  brew('gdu').sans_arm(), // disk usage tui
)
