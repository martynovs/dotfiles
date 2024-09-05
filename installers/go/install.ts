#!/usr/bin/env -S node --experimental-strip-types

import { brew, go_pkg, printScript } from '../helpers.ts';

printScript(
    brew('staticcheck'), // linter
    go_pkg('kisielk/errcheck'), // check for unchecked errors
    go_pkg('melkeydev/go-blueprint'),
    go_pkg('goreleaser/goreleaser/v2'),
    go_pkg('pressly/goose/v3/cmd/goose'), // migrations cli
    go_pkg('air-verse/air'), // live reload
)
