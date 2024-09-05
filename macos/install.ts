#!/usr/bin/env -S node --experimental-strip-types

import { macos, printScript } from '../helpers.ts';

printScript(
  macos('homerow'), // gui navigation from keyboard
  macos('ghostty'), // terminal
  macos('raycast'), // spotlight replacement
  macos('alt-tab'), // alt tab with preview

  macos('obsidian'), // note taking

  macos('iina'),      // media player
  macos('handbrake'), // video converter
  macos('mediahuman-audio-converter'),

  macos('font-fira-code-nerd-font'),      // font for vscode
  macos('font-jetbrains-mono-nerd-font'), // font for terminal
)
