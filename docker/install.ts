#!/usr/bin/env -S node --experimental-strip-types

import { brew, macos, universal, printScript } from '../helpers.ts';

printScript(
    macos('lima'),       // macOS VM for docker
    macos('colima'),     // macOS VM for docker
    macos('lazydocker'), // docker tui
    universal('podman'), // container engine
    universal('podman-compose'),
    brew('podman-tui'),
    brew('ctop'),        // top for containers
    brew('helm'),        // k8s package manager
    brew('kustomize'),   // k8s templating
)
