## §D — Description

nix-cavekit is a Nix flake that packages [cavekit](https://github.com/JuliusBrussee/cavekit), a spec-driven development toolkit for AI coding agents, for use in Nix-based development environments. It provides a buildable Nix package that installs the cavekit plugin (commands, skills, and plugin metadata), a development shell with code-quality tooling (nixfmt, deadnix, statix, typos, yamllint, editorconfig-checker) and six lefthook wrapper scripts for git pre-commit hooks, and CI workflows for multi-platform builds and automated dependency pin updates. Target users are Nix developers who want to integrate cavekit into their flake-based projects.

## §V — Invariants

1. The flake must evaluate and build on all four supported systems: `aarch64-darwin`, `x86_64-darwin`, `x86_64-linux`, `aarch64-linux`.
2. `nix flake check --no-build` must pass (structural validity of the flake).
3. The `packages.default` derivation must successfully copy `plugin.json`, `FORMAT.md`, `commands/`, `skills/`, and `.claude-plugin/` from the upstream cavekit source.
4. The `devShells.default` must provide all tools listed in its `packages`: coreutils, deadnix, editorconfig-checker, git, lefthook, nix, nixfmt, typos, yamllint, plus all six lefthook wrapper scripts.
5. All shell scripts (`dev.sh`, `install-plugin.sh`) must pass ShellCheck validation (`# shellcheck shell=bash`).
6. Nix files must contain no embedded shell code (enforced by `lefthook-nix-no-embedded-shell` hook).
7. Nix files must pass nixfmt, statix, and deadnix linting (enforced by lefthook remotes).
8. YAML files must pass yamllint with the project's `.yamllint.yml` config (line-length disabled, truthy check-keys disabled).
9. Markdown files must pass markdownlint with MD013 (line length) disabled.
10. All files must use LF line endings, UTF-8 charset, 2-space indentation, have a final newline, and no trailing whitespace (enforced by `.editorconfig`).
11. The `nixpkgs` input must follow `nixpkgs-lock/nixpkgs` to ensure reproducible, pinned builds.
12. CI must build successfully on `ubuntu-latest`, `ubuntu-24.04-arm`, and `macos-latest`.

## §I — Interfaces

### Flake outputs

```
packages.<system>.default  : derivation
```

Builds the cavekit plugin. Installs `plugin.json`, `FORMAT.md`, `commands/`, `skills/`, `.claude-plugin/` into `$out/`.

```
devShells.<system>.default : derivation
devShells.<system>.ci      : derivation  (alias for default)
```

Development shell with code-quality tools and lefthook hooks.

### Flake usage (as input)

```nix
inputs.nix-cavekit = {
  url = "github:pr0d1r2/nix-cavekit";
  inputs.nixpkgs.follows = "nixpkgs";
};
# Then: nix-cavekit.packages.${system}.default
```

### Lefthook wrapper scripts (available in devShell PATH)

| Script | Purpose | Runtime deps |
|---|---|---|
| `lefthook-git-conflict-markers` | Detect unresolved conflict markers | gnugrep |
| `lefthook-git-no-local-paths` | Detect hardcoded local paths | gnugrep |
| `lefthook-missing-final-newline` | Ensure files end with newline | (none) |
| `lefthook-nix-no-embedded-shell` | Detect shell code in .nix files | (none) |
| `lefthook-statix` | Nix static analysis | statix |
| `lefthook-trailing-whitespace` | Detect trailing whitespace | gnugrep |

### Environment variables

| Variable | Set by | Purpose |
|---|---|---|
| `NIX_CONFIG` | `dev.sh` | Enables `nix-command` and `flakes` experimental features |

### Config files

| File | Format | Purpose |
|---|---|---|
| `flake.nix` | Nix | Flake definition with inputs, packages, and devShells |
| `flake.lock` | JSON | Pinned dependency versions |
| `lefthook.yml` | YAML | 12 remote lefthook hook configurations |
| `.editorconfig` | INI | Editor formatting rules |
| `.yamllint.yml` | YAML | yamllint config |
| `.markdownlint.yml` | YAML | markdownlint config |
| `.envrc` | Shell | direnv integration (`use flake`) |
| `.rtk/filters.toml` | TOML | RTK filter config (schema_version = 1) |

## §T — Tasks

| status | id | goal |
|---|---|---|
| `.` | T1 | Add `nix flake check` tests to verify the package builds and installs expected files |
| `.` | T2 | Add a CLAUDE.md with build/test/lint instructions for AI agent context |
| `.` | T3 | Update `update-pins.yml` to also pin-update `cavekit-src` and all `nix-lefthook-*-src` inputs |
| `.` | T4 | Align `actions/checkout` version in `update-pins.yml` (v4) with `ci.yml` (v6) |
| `.` | T5 | Add a `nix-lefthook-markdownlint` remote hook to lefthook.yml or document why it is omitted |
| `.` | T6 | Differentiate `devShells.ci` from `default` (e.g., exclude interactive tools, add CI-only checks) or remove the alias |
| `.` | T7 | Add input validation in `install-plugin.sh` to fail clearly if expected upstream paths are missing |
| `.` | T8 | Add a `nix-lefthook-shellcheck` remote hook to lint `dev.sh` and `install-plugin.sh` on commit |
| `.` | T9 | Document all six lefthook wrapper scripts in README.md for downstream consumers |

## §B — Bugs / Known Issues

1. **checkout version mismatch**: `update-pins.yml` uses `actions/checkout@v4` while `ci.yml` uses `actions/checkout@v6`. This is inconsistent and `v4` may miss security or feature fixes.
2. **Partial pin update coverage**: The `update-pins.yml` workflow only runs `nix flake update nixpkgs-lock`. The six `nix-lefthook-*-src` and `cavekit-src` inputs are never automatically updated, so they can drift silently.
3. **No build output verification**: There are no tests that the `packages.default` derivation actually produces the expected file layout. If cavekit upstream renames or removes `plugin.json`, `commands/`, `skills/`, or `.claude-plugin/`, the build may fail or produce an incomplete result with no early signal.
4. **Fragile `nix-no-embedded-shell` wrapper**: The `lefthook-nix-no-embedded-shell` wrapper injects a `SCANNER` variable via string concatenation before the upstream script body. If the upstream script changes its assumptions about how `SCANNER` is set, this will break silently.
5. **`ci` devShell is an exact alias**: `ci = default` provides no distinction. CI runs with `skip-lefthook: 'true'` anyway, so the lefthook wrappers bundled in the shell are dead weight in CI context.
6. **No `deadnix` lefthook wrapper**: `deadnix` is listed in lefthook remotes and as a devShell package, but unlike statix it has no corresponding `lefthookWrappersFor` entry. This is correct (the remote runs `deadnix` directly) but inconsistent with how statix is handled (which has both a remote and a wrapper).
