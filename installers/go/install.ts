#!/usr/bin/env -S node --experimental-strip-types

import { go_pkg, printScript } from '../helpers.ts';

printScript(
    go_pkg('melkeydev/go-blueprint'),
    go_pkg('goreleaser/goreleaser/v2'),
    go_pkg('pressly/goose/v3/cmd/goose'), // migrations cli
    go_pkg('air-verse/air'), // live reload
)
