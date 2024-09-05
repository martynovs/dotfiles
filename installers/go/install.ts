#!/usr/bin/env -S node --experimental-strip-types

import { go_pkg, printScript } from '../helpers.ts';

printScript(
    go_pkg('melkeydev/go-blueprint'),
)
