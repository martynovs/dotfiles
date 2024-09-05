#!/usr/bin/env -S node --experimental-strip-types

import { cargobin, printScript, macos } from '../helpers.ts';

printScript(
    macos('tla+-toolbox'), // tla+ ui
    cargobin('tlauc'),     // unicode converter for tla specs
)
