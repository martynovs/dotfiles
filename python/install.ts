#!/usr/bin/env -S node --experimental-strip-types

import { brew, printScript } from '../helpers.ts';

printScript(
    brew('python'),
    brew('poetry'), // package manager
    brew('uv'),     // python env and package manager
    brew('ruff'),   // linter
)
