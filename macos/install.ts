#!/usr/bin/env -S node --experimental-strip-types

import { macos, printScript } from '../helpers.ts';

printScript(
  macos('ghostty'), // terminal
  macos('raycast'), // spotlight replacement
  macos('alt-tab'), // alt tab with preview
  macos('hazeover'), // dim non focused windows

  macos('homerow'), // gui clicks and scroll from keyboard
  macos('bettertouchtool'), // custom gestures and shortcuts

  macos('obsidian'), // note taking
  macos('shottr'), // nice screenshots

  macos('iina'),      // media player
  macos('recut'),     // remove pauses from videos
  macos('handbrake'), // video converter
  macos('mediahuman-audio-converter'),

  macos('font-fira-code-nerd-font'),      // font for vscode
  macos('font-jetbrains-mono-nerd-font'), // font for terminal
)
