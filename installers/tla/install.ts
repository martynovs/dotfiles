#!/usr/bin/env -S node --experimental-strip-types

import { cargo_bin, printScript, macos, brew } from '../helpers.ts';

printScript(
    macos(
        brew('tla+-toolbox'), // tla+ ui
        cargo_bin('tlauc'),   // unicode converter for tla specs
    ),
)
