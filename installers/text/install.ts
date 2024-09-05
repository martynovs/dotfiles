#!/usr/bin/env -S bun run

import { brew, printScript } from '../helpers.ts';

printScript(
  // PDF writing tools
  brew('typst'),
  brew('tinymist'), // langserver

  // Markdown writing tools
  brew('glow').sans_arm(),
  brew('markdown-oxide'), // langserver

  // Presentation tools
  brew('presenterm'),
  brew('charmbracelet/tap/freeze').tap('charmbracelet/tap'), // images from code or terminal output
)
