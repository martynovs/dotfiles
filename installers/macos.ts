#!/usr/bin/env -S bun run

import { brew, macos, optional, printScript } from './_helpers.ts';

printScript(macos(
  // Basic apps
  brew('brave-browser').cask(),
  brew('zen-browser').cask(),
  brew('raindropio').cask(),
  brew('telegram').cask(),
  brew('obsidian').cask(),
  brew('raycast').cask(),
  brew('ghostty').cask(),
  brew('iina').cask(),

  // Keyboard/mouse/touchpad improvements
  brew('kanata'),
  brew('homerow').cask(),
  brew('hammerspoon').cask(),
  brew('karabiner-elements').cask(),
  brew('linearmouse').cask(),
  // brew('bettertouchtool').cask(),
  // brew('keyboard-maestro').cask(),

  // Display improvements
  brew('betterdisplay').cask(),
  brew('nikitabobko/tap/aerospace').cask(),
  brew('hazeover').cask(),
  brew('topnotch').cask(),
  brew('alt-tab').cask(),

  // Development tools
  brew('opencode'),
  brew('gemini-cli'),
  brew('block-goose-cli'),
  brew('steveyegge/beads/bd'),
  brew('kiro-cli').cask(),
  brew('superwhisper').cask(),
  brew('visual-studio-code').cask(),

  // Networking
  brew('localsend').cask(),
  brew('proxychains-ng'),

  optional('Encryption',
    brew('age-plugin-yubikey'),
    brew('age-plugin-se'), // generate age keys with Apple Secure Enclave
    brew('yubico-authenticator').cask(),
  ),

  optional('Screen capturing',
    brew('shottr').cask(),    // nice screenshots
    brew('cleanshot').cask(), // screenshot and screen recording
    brew('keycastr').cask(),  // show keystrokes on screen
  ),

  optional('Media converters',
    brew('handbrake').cask(), // video converter
    brew('recut').cask(),     // remove pauses from videos
    brew('permute').cask(),   // audio/video converter
    brew('mediahuman-audio-converter').cask(),
  ),

  brew('font-fira-code-nerd-font'),      // font for vscode
  brew('font-jetbrains-mono-nerd-font'), // font for terminal
))
