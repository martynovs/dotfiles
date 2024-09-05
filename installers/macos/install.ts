#!/usr/bin/env -S node --experimental-strip-types

import { brew, macos, optional, printScript } from '../helpers.ts';

printScript(macos(
  // Basic apps
  brew('brave-browser'),
  brew('zen-browser'),
  brew('raindropio'),
  brew('telegram'),
  brew('obsidian'),
  brew('raycast'),
  brew('ghostty'),
  brew('iina'),

  // Editors/agents
  brew('amazon-q'),
  brew('gemini-cli'),
  brew('superwhisper'),
  brew('visual-studio-code'),

  // Keyboard/mouse/touchpad improvements
  brew('kanata'),
  brew('homerow'),
  brew('hammerspoon'),
  brew('karabiner-elements'),
  brew('linearmouse'),
  // brew('bettertouchtool'),
  // brew('keyboard-maestro'),
  // brew('jackielii/tap/skhd-zig'),

  // Display improvements
  brew('betterdisplay'),
  brew('nikitabobko/tap/aerospace'),
  brew('hazeover'),
  brew('topnotch'),
  brew('alt-tab'),

  // networking
  brew('proxychains-ng'),

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
