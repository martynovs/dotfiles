#!/usr/bin/env -S bun run

import { brew, printScript } from '../helpers.ts';

printScript(
  // PDF writing tools
  brew('typst').gh('typst/typst'),
  brew('tinymist').gh('Myriad-Dreamin/tinymist'), // langserver

  // Markdown writing tools
  brew('glow').gh('charmbracelet/glow'),
  brew('markdown-oxide').gh('Feel-ix-343/markdown-oxide'), // langserver

  // Presentation tools
  brew('presenterm').gh('mfontanini/presenterm'),
  brew('charmbracelet/tap/freeze').gh('charmbracelet/freeze'), // images from code or terminal output
)
