#!/usr/bin/env -S bun run

import { brew, native, printScript } from './_helpers.ts';

printScript(
    // docker tools
    brew('dive').gh('wagoodman/dive'),
    brew('tokuhirom/tap/dcv').gh('tokuhirom/dcv'),
    // brew('psviderski/tap/uncloud').gh('psviderski/uncloud'),

    // podman tools
    native('podman'),
    native('podman-compose'),
    brew('podman-tui').gh('containers/podman-tui'),

    // k8s tools
    brew('helm').gh('helm/helm'),
    brew('kustomize').gh('kubernetes-sigs/kustomize'),
)
