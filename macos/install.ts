#!/usr/bin/env -S node --experimental-strip-types

import { macos, optional, printScript } from '../helpers.ts';

printScript(
  macos('brave-browser'),
  macos('zen-browser'),
  macos('raindropio'),
  macos('telegram'),
  macos('raycast'),
  macos('alt-tab'),
  macos('ghostty'),
  macos('neovide'),
  macos('iina'),

  // Keyboard improvements
  macos('homerow'),
  macos('karabiner-elements'),
  macos('houmain/tap/keymapper --head'),
  // macos('bettertouchtool'),
  // macos('keyboard-maestro'),

  // Display improvements
  macos('betterdisplay'),
  macos('nikitabobko/tap/aerospace'),
  macos('dimentium/autoraise/autoraiseapp'),
  macos('hazeover'),

  // Markdown writing tools
  macos('obsidian'),
  macos('presenterm'), // md presentations in terminal
  macos('glow'), // md preview in terminal

  optional('Screen capturing',
    macos('shottr'),    // nice screenshots
    macos('cleanshot'), // screenshot and screen recording
  ),

  optional('Media converters',
    macos('handbrake'), // video converter
    macos('recut'),     // remove pauses from videos
    macos('permute'),   // audio/video converter
    macos('mediahuman-audio-converter'),
  ),

  macos('font-fira-code-nerd-font'),      // font for vscode
  macos('font-jetbrains-mono-nerd-font'), // font for terminal
)
