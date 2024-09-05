#!/usr/bin/env -S bun run

import { brew, macos, native, printScript } from '../helpers.ts';

printScript(
    brew('psviderski/tap/uncloud'),
    macos(
        brew('lima'),   // macOS VM for docker
        brew('colima'), // macOS VM for docker
    ),
    native('podman'),
    native('podman-compose'),
    brew('lazydocker').sans_arm(),
    brew('podman-tui'),
    brew('dive'),        // analyze docker images
    brew('ctop'),        // top for containers
    brew('helm'),        // k8s package manager
    brew('kustomize'),   // k8s templating
)
