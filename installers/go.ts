#!/usr/bin/env -S bun run

import { go_pkg, printScript } from './_helpers.ts';

printScript(
    go_pkg('google/capslock/cmd/capslock'), // dependencies analyzer
    go_pkg('honnef.co/go/tools/cmd/staticcheck'), // linter
    go_pkg('kisielk/errcheck'), // check for unchecked errors
    go_pkg('melkeydev/go-blueprint'),
    go_pkg('goreleaser/goreleaser/v2'),
    go_pkg('pressly/goose/v3/cmd/goose'), // migrations cli
    go_pkg('air-verse/air'), // live reload
)
