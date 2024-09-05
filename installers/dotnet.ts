#!/usr/bin/env -S bun run

import { apt, brew, cargo, dnf, macos, printScript } from './_helpers.ts';

printScript(
    dnf('dotnet-sdk-aot-9.0'),
    apt('dotnet-sdk-9.0').ppa('dotnet/backports'),
    macos(brew('dotnet-sdk').tap('isen-ng/dotnet-sdk-versions')),
    // TODO: install https://github.com/Samsung/netcoredbg
    cargo('github.com/SofusA/csharp-language-server'),
)
