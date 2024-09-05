#!/usr/bin/env -S bun run

import { brew, cargo, printScript } from './_helpers.ts';

printScript(
    brew('python').gh('python/cpython'),
    brew('uv').gh('astral-sh/uv'),
    brew('ruff').gh('astral-sh/ruff'), // linter
    brew('black').gh('psf/black'), // formatter
    brew('pyrefly').gh('facebook/pyrefly'), // type checker and lang server

    brew('duckdb').gh('duckdb/duckdb'),
    brew('lazysql').gh('jorgerojas26/lazysql'),
    cargo('datahobbit'),
)
