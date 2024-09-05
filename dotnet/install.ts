#!/usr/bin/env -S node --experimental-strip-types

import { apt, dnf, macos, printScript } from '../helpers.ts';

printScript(
    dnf('dotnet-sdk-aot-9.0'),
    apt('dotnet-sdk-9.0').ppa('dotnet/backports'),
    macos('dotnet-sdk').tap('isen-ng/dotnet-sdk-versions'),
)
