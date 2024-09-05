#!/usr/bin/env -S node --experimental-strip-types

import { brew, go_pkg, native, linux, macos, printScript } from '../helpers.ts';

printScript(
  brew('go'), // to install cli go packages

  // shell
  brew('fish'),
  brew('fisher'),
  brew('starship'),
  native('direnv'), // .env/.envrc

  // editing and development
  brew('nvim'),
  brew('just'),
  brew('mask'), // poetic 'just'
  brew('watchexec'),
  brew('jq'),
  brew('jfryy/tap/qq'), // interactive viewer + transcoder for json/yaml/toml/xml/csv etc.
  brew('wader/tap/fq'), // decoder for lots of binary formats (media, protobuf, bson, avro, etc.)
  macos('dasel'), // configuration files editor
  linux(go_pkg('tomwright/dasel/v2/cmd/dasel')),
  macos('gum'), // helpers for nice shell scripts

  // basic cli
  brew('fastfetch'),  // system information
  brew('zoxide'),     // cd with history
  brew('eza'),        // ls with colors
  brew('bat'),        // cat with colors
  brew('bat-extras'), // batman and more
  brew('sd'),         // sed/awk for mere mortals
  brew('fd'),         // find
  brew('fselect'),    // find with SQL like syntax
  brew('ripgrep'),    // grep
  brew('broot'),      // directory tree tui
  native('fzf'),      // fuzzy finder with tui
  brew('xh'),         // http client
  macos('gdu'),       // disk usage tui
  // linux(go_pkg('dundee/gdu/v5/cmd/gdu')),
)
