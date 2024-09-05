#!/usr/bin/env -S bun run

import { brew, cargo, printScript } from './_helpers.ts';

printScript(
    brew('rust').gh('rust-lang/rust'),

    // lsp
    cargo('ra-multiplex'),        // rust analyzer lsp mux https://github.com/pr2502/ra-multiplex

    // dependency management
    cargo('cargo-seek'),          // https://github.com/tareqimbasher/cargo-seek
    cargo('cargo-outdated'),      // https://github.com/kbknapp/cargo-outdated
    cargo('cargo-shear'),         // https://github.com/Boshen/cargo-shear
    cargo('cargo-hakari'),        // https://github.com/guppy-rs/guppy
    cargo('cargo-audit'),         // https://github.com/RustSec/rustsec/tree/main/cargo-audit
    cargo('cargo-about'),         // https://github.com/EmbarkStudios/cargo-about
    cargo('cargo-deny'),          // https://github.com/EmbarkStudios/cargo-deny

    // build tools
    cargo('cargo-semver-checks'), // https://github.com/obi1kenobi/cargo-semver-checks
    cargo('cargo-auditable'),     // https://github.com/rust-secure-code/cargo-auditable 

    // run/test tools
    cargo('bacon'),               // https://github.com/Canop/bacon
    cargo('cargo-selector'),      // https://github.com/lusingander/cargo-selector
    cargo('cargo-nextest'),       // https://github.com/nextest-rs/nextest
    cargo('cargo-tarpaulin'),     // https://github.com/xd009642/tarpaulin

    // other tools
    cargo('rusty-man'),           // https://github.com/Canop/rusty-man
    cargo('cargo-sort-derives'),  // https://github.com/lusingander/cargo-sort-derives
    cargo('cargo-expand'),        // https://github.com/dtolnay/cargo-expand
    // cargo('cargo-modules'),       // https://github.com/regexident/cargo-modules
    // cargo('cargo-show-asm'),      // https://github.com/pacak/cargo-show-asm
)
