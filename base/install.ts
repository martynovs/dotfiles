#!/usr/bin/env -S node --experimental-strip-types

import { brew, universal, printScript } from '../helpers.ts';

printScript(
  brew('go'), // to install cli go packages

  // shell
  brew('fish'), // nice shell
  brew('fisher'), // fish plugin manager
  brew('starship'), // shell prompt
  universal('direnv'), // load/unload .env and .envrc files when changing directory

  // editing and development
  brew('nvim'), // neovim
  brew('just'), // simple alternative to 'make'
  brew('watchexec'), // run commands when files change
  brew('jq'), // json processor
  brew('jfryy/tap/qq'), // interactive viewer + transcoder for json/yaml/toml/xml/csv etc.
  brew('wader/tap/fq'), // decoder for lots of binary formats (media, protobuf, bson, avro, etc.)
  brew('dasel').go_pkg('tomwright/dasel/v2/cmd/dasel'), // configuration files editor
  brew('glow').go_pkg('charmbracelet/glow'), // markdown previewer for terminal
  brew('gum').go_pkg('charmbracelet/gum'), // helpers for nice shell scripts

  // basic cli
  brew('zoxide'),  // cd with history
  brew('eza'),     // ls with colors
  brew('bat'),     // cat with colors
  brew('sd'),      // sed/awk for mere mortals
  brew('fd'),      // find
  brew('ripgrep'), // grep
  brew('broot'),   // directory tree tui
  universal('fzf'),   // fuzzy finder with tui
  universal('wget'),  // file downloader
  brew('gdu').go_pkg('dundee/gdu/v5/cmd/gdu'), // disk usage tui
)
