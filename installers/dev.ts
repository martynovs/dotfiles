#!/usr/bin/env -S bun run

import { brew, eget, npm, printScript } from './_helpers.ts';

printScript(
  // git/jj
  brew('gh').gh('cli/cli'),
  brew('dra').gh('devmatteini/dra'), // download from GitHub releases
  brew('lazygit').gh('jesseduffield/lazygit'),
  brew('git-who').gh('sinclairtarget/git-who'),
  brew('diff-so-fancy').gh('so-fancy/diff-so-fancy'),
  brew('git-delta').gh('dandavison/delta'),
  brew('jj').gh('jj-vcs/jj'),
  brew('jjui').gh('idursun/jjui'),

  // encryption
  brew('gopass'), // password manager
  brew('sops'), // encrypt/decrypt secrets with various key providers (including age)
  brew('age'), // local keys manager with file encryption/decryption

  // dev tools
  brew('xh').gh('ducaale/xh'), // http client
  brew('pastel').gh('sharkdp/pastel'), // color management
  brew('posting').gh('darrenburns/posting'), // postman like tui
  brew('felangga/chiko/chiko').gh('felangga/chiko'), // grpc tui
  eget('unkn0wn-root/resterm'), // rest/graphql/grpc runner tui
  brew('gonzo').gh('control-theory/gonzo'), // logs navigation
  brew('tailspin').gh('bensadeh/tailspin'), // colored tail
  brew('tokei').gh('XAMPPRocky/tokei'), // nice 'loc'

  // build/test
  // brew('hyperfine').gh('sharkdp/hyperfine'),
  // brew('cmake').gh('Kitware/CMake'),
  // brew('ninja').gh('ninja-build/ninja'),
  brew('just').gh('casey/just'),
  // brew('mask').gh('jacobdeichert/mask'), // poetic 'just'
  brew('sccache').gh('mozilla/sccache'),
  // brew('watchexec').gh('watchexec/watchexec'),

  // lang servers
  // brew('superhtml').gh('kristoff-it/superhtml'),
  // brew('typescript-language-server').gh('typescript-language-server/typescript-language-server'),

  // zig
  // brew('zig').gh('ziglang/zig'),
  // brew('zls').gh('zigtools/zls'),

  // data manipulation
  brew('srgn').gh('alexpovel/srgn'), // syntax aware grep
  brew('grex').gh('pemistahl/grex'), // build regexp from examples
  brew('igrep').gh('konradsz/igrep'), // interactive grep
  brew('jq').gh('jqlang/jq'), // json processor
  brew('fx').gh('antonmedv/fx'), // interactive json/yaml viewer
  brew('jqp').gh('noahgorstein/jqp'), // jq TUI
  brew('dasel').gh('TomWright/dasel'), // query and manipulate json, yaml, toml, xml, csv, etc.
  brew('toml2json').gh('woodruffw/toml2json'),
  brew('ynqa/tap/sigrs').gh('ynqa/sig'), // interactive grep with streaming
  brew('jfryy/tap/qq').gh('jfryy/qq'), // interactive viewer + transcoder for json, yaml, toml, xml, csv, etc.
  brew('wader/tap/fq').gh('wader/fq'), // decoder for lots of binary formats (media, protobuf, bson, avro, etc.)
)
