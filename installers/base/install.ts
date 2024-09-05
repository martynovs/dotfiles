#!/usr/bin/env -S bun run

import { brew, native, printScript } from '../helpers.ts';

printScript(
  // shell
  brew('fish'),
  brew('fisher'),
  brew('starship'),
  native('direnv'),

  // tmux
  brew('tmux'),
  brew('tpm'),
  brew('sesh').sans_arm(),

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
  brew('jq'),         // json processor
  brew('jqp'),        // jq TUI

  // basic system monitoring
  brew('gromgit/brewtils/taproom').tap('gromgit/brewtils'), // brew tui
  brew('fastfetch'),  // system information
  brew('btop'),       // system monitor
  brew('bottom'),     // system monitor with temperature info
  brew('duf'),        // df with colors
  brew('gdu').sans_arm(), // disk usage tui
)
