#!/usr/bin/env -S node --experimental-strip-types

import { brew, macos, optional, printScript } from '../helpers.ts';

printScript(macos(
  brew('brave-browser'),
  brew('zen-browser'),
  brew('raindropio'),
  brew('telegram'),
  brew('raycast'),
  brew('alt-tab'),
  brew('ghostty'),
  brew('iina'),

  // Keyboard/mouse/touchpad improvements
  brew('homerow'),
  brew('karabiner-elements'),
  brew('houmain/tap/keymapper --head'),
  brew('linearmouse'),
  brew('bettertouchtool'),
  // brew('keyboard-maestro'),

  // Display improvements
  brew('betterdisplay'),
  brew('nikitabobko/tap/aerospace'),
  brew('dimentium/autoraise/autoraiseapp'),
  brew('hazeover'),

  // Markdown writing tools
  brew('obsidian'),
  brew('presenterm'),
  brew('glow'),

  optional('Screen capturing',
    brew('shottr'),    // nice screenshots
    brew('cleanshot'), // screenshot and screen recording
    brew('keycastr'),  // show keystrokes on screen
  ),

  optional('Media converters',
    brew('handbrake'), // video converter
    brew('recut'),     // remove pauses from videos
    brew('permute'),   // audio/video converter
    brew('mediahuman-audio-converter'),
  ),

  brew('font-fira-code-nerd-font'),      // font for vscode
  brew('font-jetbrains-mono-nerd-font'), // font for terminal
))
