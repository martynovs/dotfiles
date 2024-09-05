#!/usr/bin/env -S bun run

import { brew, printScript } from './_helpers.ts';

printScript(
  // shell
  brew('fish').gh('fish-shell/fish-shell'),
  brew('fisher').gh('jorgebucaran/fisher'),
  brew('direnv').gh('direnv/direnv'),
  brew('starship').gh('starship/starship'),

  // tmux
  brew('tmux').gh('tmux/tmux'),
  brew('tpm').gh('tmux-plugins/tpm'),
  brew('sesh').gh('joshmedeski/sesh'),

  // editor
  brew('helix').gh('helix-editor/helix'),
  brew('yazi').gh('sxyazi/yazi'),

  // basic cli
  brew('uv').gh('astral-sh/uv'),
  brew('fzf').gh('junegunn/fzf'),
  brew('gum').gh('charmbracelet/gum'),
  brew('sd').gh('chmln/sd'), // sed/awk for mere mortals
  brew('fd').gh('sharkdp/fd'), // find
  brew('ripgrep').gh('BurntSushi/ripgrep'), // grep
  brew('zoxide').gh('ajeetdsouza/zoxide'), // cd with history
  brew('eza').gh('eza-community/eza'), // ls and tree with colors
  brew('bat').gh('sharkdp/bat'), // cat with colors
  brew('bat-extras').gh('eth-p/bat-extras'), // batman, batgrep and more
  brew('btop').gh('aristocratos/btop'), // system monitor
  brew('fastfetch').gh('fastfetch-cli/fastfetch'), // system information
  brew('duf').gh('muesli/duf'), // df with colors
  brew('gdu').gh('dundee/gdu'), // disk usage tui
)
