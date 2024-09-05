#!/usr/bin/env -S bun run

import { brew, cargo, printScript } from '../helpers.ts';

printScript(
    brew('python'),
    brew('uv'),
    brew('ruff'), // linter
    brew('black'), // formatter

    brew('duckdb'),
    cargo('datahobbit'),
)
