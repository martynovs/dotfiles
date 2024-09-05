#!/usr/bin/env -S bun run

import { brew, macos, printScript } from '../helpers.ts';

printScript(
  brew('opencode').npm('opencode-ai'),
  brew('gemini-cli').npm('@google/gemini-cli'),

  macos(
    brew('amazon-q').cask(),
    brew('superwhisper').cask(),
    brew('visual-studio-code').cask(),
  ),
)
