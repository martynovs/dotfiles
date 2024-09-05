#!/usr/bin/env -S node --experimental-strip-types

import { brew, universal, printScript } from '../helpers.ts';

printScript(
  // shell
  brew('fish'), // nice shell
  brew('fisher'), // fish plugin manager
  brew('starship'), // shell prompt
  universal('direnv'), // load/unload .env and .envrc files when changing directory

  // editing
  brew('nvim'), // neovim
  brew('jfryy/tap/qq'), // interactive viewer + transcoder for json/yaml/toml/xml/csv etc.
  brew('wader/tap/fq'), // decoder for lots of binary formats (media, protobuf, bson, avro, etc)
  brew('dasel').go_pkg('tomwright/dasel/v2/cmd/dasel'), // configuration files editor
  brew('glow').go_pkg('charmbracelet/glow'), // markdown previewer for terminal
  brew('gum').go_pkg('charmbracelet/gum'), // helpers for nice shell scripts

  // version control
  universal('gh'),
  brew('git'),
  brew('lazygit').go_pkg('jesseduffield/lazygit'), // git tui
  brew('git-delta'), // colored git diff
  brew('jj'),   // modern git alternative
  brew('jjui'), // jj terminal ui

  // basic cli
  brew('just'),    // 'make' replacement
  brew('zoxide'),  // cd
  brew('eza'),     // ls
  brew('bat'),     // cat
  brew('tokei'),   // loc
  brew('fd'),      // find
  brew('ripgrep'), // grep
  brew('broot'),   // directory tree tui
  universal('fzf'),   // fuzzy finder with tui
  universal('wget'),  // file downloader
  brew('gdu').go_pkg('dundee/gdu/v5/cmd/gdu'), // disk usage tui
)
