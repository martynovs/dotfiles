#!/usr/bin/env -S bun run

import { brew, macos, optional, printScript } from '../helpers.ts';

printScript(
    brew('sops').gh('getsops/sops'), // encrypt/decrypt secrets with various key providers
    brew('age').gh('FiloSottile/age'), // local keys manager with file encryption/decryption

    macos(
        brew('age-plugin-se').gh('remko/age-plugin-se'),      // generate age keys with Apple Secure Enclave
        optional("Yubikey support",
            brew('age-plugin-yubikey').gh('str4d/age-plugin-yubikey'), // generate age keys with Yubikey
            brew('yubico-yubikey-manager').gh('Yubico/yubikey-manager'),
        ),
    ),
)
