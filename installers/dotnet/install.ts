#!/usr/bin/env -S node --experimental-strip-types

import { apt, brew, dnf, macos, printScript } from '../helpers.ts';

printScript(
    dnf('dotnet-sdk-aot-9.0'),
    apt('dotnet-sdk-9.0').ppa('dotnet/backports'),
    macos(brew('dotnet-sdk').tap('isen-ng/dotnet-sdk-versions')),
    // TODO: install https://github.com/Samsung/netcoredbg
)
