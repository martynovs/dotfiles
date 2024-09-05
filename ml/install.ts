#!/usr/bin/env -S node --experimental-strip-types

import { brew, printScript } from '../helpers.ts';

printScript(
    brew('duckdb'),
    brew('python'),
    brew('poetry'),
    brew('uv'),
    brew('ruff'),
)
