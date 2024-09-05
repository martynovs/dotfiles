#!/usr/bin/env -S node --experimental-strip-types

import { brew, printScript } from '../helpers.ts';

printScript(
  // PDF writing tools
  brew('typst'),
  brew('tinymist'), // langserver

  // Markdown writing tools
  brew('glow'),
  brew('presenterm'),
  brew('markdown-oxide'), // langserver
)
