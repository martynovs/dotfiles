#!/usr/bin/env -S node --experimental-strip-types

import { brew, macos, npm, printScript } from '../helpers.ts';

printScript(
  // AI tools
  macos(
    brew('gemini-cli'),
    brew('amazon-q').cask(),
    brew('superwhisper').cask(),
  ),

  // git/jj
  brew('gh').sans_arm(),
  brew('git'),
  brew('gitui'),
  brew('lazygit').sans_arm(),
  npm('branchlet'),
  brew('diff-so-fancy'),
  brew('git-delta'),
  brew('jj'),
  brew('jjui').sans_arm(),

  // dev tools
  brew('uv'),
  brew('pastel'),    // color management
  brew('posting'),   // postman like tui
  brew('peco'),      // interactive logs filter
  brew('tailspin'),  // colored tail
  brew('tokei'),     // nice 'loc'
  brew('backlog-md'),

  // build/test
  brew('hyperfine'),
  brew('cmake'),
  brew('ninja'),
  brew('just'),
  brew('mask'), // poetic 'just'
  brew('sccache'),
  brew('watchexec'),

  // lang servers
  brew('superhtml'),
  brew('typescript-language-server'),

  // data manipulation
  brew('fx').sans_arm(),    // interactive json/yaml viewer
  brew('dasel').sans_arm(), // query and manipulate json, yaml, toml, xml, csv, etc.
  brew('rnr'),              // rename files with regex
  brew('f2').sans_arm(),    // rename files using metadata
  brew('toml2json'),
  brew('jfryy/tap/qq').tap('jfryy/tap'), // interactive viewer + transcoder for json, yaml, toml, xml, csv, etc.
  brew('wader/tap/fq').tap('wader/tap'), // decoder for lots of binary formats (media, protobuf, bson, avro, etc.)
)
