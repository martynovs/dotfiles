#!/usr/bin/env -S bun run

import { cargo, printScript, macos, brew } from '../helpers.ts';

printScript(
    macos(
        brew('tla+-toolbox'), // tla+ ui
        cargo('tlauc'),   // unicode converter for tla specs
    ),
)
