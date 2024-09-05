#!/usr/bin/env -S node --experimental-strip-types

import { brew, native, printScript } from '../helpers.ts';

printScript(
  // env
  native('direnv'),

  // ai
  brew('gemini-cli'),
  brew('opencode'),

  // tmux
  brew('tmux'),
  brew('tpm'),
  brew('sesh').sans_arm(),

  // git/jj
  brew('gh').sans_arm(),
  brew('git'),
  brew('gitui'),
  brew('lazygit').sans_arm(),
  brew('git-delta'),
  brew('jj'),
  brew('jjui').sans_arm(),

  // build/test
  brew('hyperfine'),
  brew('cmake'),
  brew('ninja'),
  brew('just'),
  brew('mask'), // poetic 'just'
  brew('sccache'),
  brew('watchexec'),

  // logs
  brew('peco'),     // interactive logs filter
  brew('tailspin'), // colored tail

  // monitoring
  brew('btop'),      // system resource monitor
  brew('bottom'),    // another system resource monitor
  brew('bandwhich'), // bandwidth usage

  // fs
  brew('rnr'),            // rename files with regex
  brew('f2').sans_arm(),  // rename files using metadata
  brew('duf'),            // df with colors
  brew('gdu').sans_arm(), // disk usage tui

  // data manipulation
  brew('jq'),
  brew('fx').sans_arm(),    // interactive json/yaml viewer
  brew('dasel').sans_arm(), // query and manipulate json, yaml, toml, xml, csv, etc.
  brew('toml2json'),
  brew('jfryy/tap/qq').tap('jfryy/tap'), // interactive viewer + transcoder for json, yaml, toml, xml, csv, etc.
  brew('wader/tap/fq').tap('wader/tap'), // decoder for lots of binary formats (media, protobuf, bson, avro, etc.)

  // nice stuff
  brew('tokei'),          // nice 'loc'
  brew('gum').sans_arm(), // helpers for nice shell scripts
)
