#!/usr/bin/env -S node --experimental-strip-types

import { brew, cargo, printScript } from '../helpers.ts';

printScript(
    brew('python'),
    brew('uv'),
    brew('ruff'),

    brew('duckdb'),
    cargo('datahobbit'),
)
