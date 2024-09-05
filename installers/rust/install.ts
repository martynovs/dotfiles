#!/usr/bin/env -S node --experimental-strip-types

import { brew, cargo, printScript } from '../helpers.ts';

printScript(
    brew('rust'),

    brew('cargo-auditable'),  // auditable build https://github.com/rust-secure-code/cargo-auditable 
    brew('cargo-audit'),      // audit checks https://github.com/RustSec/rustsec/tree/main/cargo-audit
    brew('cargo-about'),      // show list of all licenses, features, etc. https://github.com/EmbarkStudios/cargo-about
    brew('cargo-deny'),       // various checks (licenses, features, etc.) https://github.com/EmbarkStudios/cargo-deny

    brew('cargo-nextest'),    // better test runner https://github.com/nextest-rs/nextest

    cargo('rusty-man'),       // man for symbols from rustdoc
    cargo('cargo-selector'),  // select and execute binary/example targets https://github.com/lusingander/cargo-selector

    cargo('cargo-semver-checks'), // check semver violations https://github.com/obi1kenobi/cargo-semver-checks
    cargo('cargo-expand'),        // show result of macro expansion https://github.com/dtolnay/cargo-expand 
    cargo('cargo-outdated'),      // find outdated dependencies https://github.com/kbknapp/cargo-outdated
    cargo('cargo-shear'),         // remove unused dependencies https://github.com/Boshen/cargo-shear
    // cargo('cargo-hakari'),        // manage workspace-hack crates to improve build time https://github.com/guppy-rs/guppy
    // cargo('cargo-modules'),       // show tree of modules https://github.com/regexident/cargo-modules
    // cargo('cargo-show-asm'),      // show generated assembly https://github.com/pacak/cargo-show-asm
    // cargo('cargo-sort-derives'),  // sort derive attributes https://github.com/lusingander/cargo-sort-derives
)
