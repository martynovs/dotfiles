#!/usr/bin/env -S node --experimental-strip-types

import { brew, macos, universal, printScript } from '../helpers.ts';

printScript(
    brew('sops').github('getsops/sops'), // encrypt/decrypt secrets with various key providers

    universal('age'), // local keys manager with file encryption/decryption

    macos('age-plugin-se'),      // generate age keys with Apple Secure Enclave
    macos('age-plugin-yubikey'), // generate age keys with Yubikey
)
