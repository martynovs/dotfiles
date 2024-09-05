#!/usr/bin/env -S bun run

import { brew, macos, optional, printScript } from '../helpers.ts';

printScript(macos(
  // Basic apps
  brew('brave-browser').gh('brave/brave-browser'),
  brew('zen-browser').gh('zen-browser/desktop'),
  brew('raindropio').gh('raindropio/desktop'),
  brew('telegram').gh('telegramdesktop/tdesktop'),
  brew('obsidian').gh('obsidianmd/obsidian-releases'),
  brew('raycast').gh('raycast/extensions'),
  brew('ghostty').gh('ghostty-org/ghostty'),
  brew('iina').gh('iina/iina'),

  // Keyboard/mouse/touchpad improvements
  brew('kanata').gh('jtroo/kanata'),
  brew('homerow').gh('nchudleigh/homerow'),
  brew('hammerspoon').gh('Hammerspoon/hammerspoon'),
  brew('karabiner-elements').gh('pqrs-org/Karabiner-Elements'),
  brew('linearmouse').gh('linearmouse/linearmouse'),
  // brew('bettertouchtool'),
  // brew('keyboard-maestro'),
  // brew('jackielii/tap/skhd-zig'),

  // Display improvements
  brew('betterdisplay').gh('waydabber/BetterDisplay'),
  brew('nikitabobko/tap/aerospace').gh('nikitabobko/aerospace'),
  brew('hazeover'),
  brew('topnotch').gh('topnotchapp/TopNotch'),
  brew('alt-tab').gh('lwouis/alt-tab-macos'),

  // networking
  brew('localsend').gh('localsend/localsend').cask(),
  brew('proxychains-ng').gh('rofl0r/proxychains-ng'),
  brew('gromgit/brewtils/taproom').gh('gromgit/taproom'), // brew tui

  optional('Screen capturing',
    brew('shottr'),    // nice screenshots
    brew('cleanshot'), // screenshot and screen recording
    brew('keycastr').gh('keycastr/keycastr'),  // show keystrokes on screen
  ),

  optional('Media converters',
    brew('handbrake').gh('HandBrake/HandBrake'), // video converter
    brew('recut'),     // remove pauses from videos
    brew('permute'),   // audio/video converter
    brew('mediahuman-audio-converter'),
  ),

  brew('font-fira-code-nerd-font').gh('ryanoasis/nerd-fonts'),      // font for vscode
  brew('font-jetbrains-mono-nerd-font').gh('ryanoasis/nerd-fonts'), // font for terminal
))
