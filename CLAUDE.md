# CLAUDE.md

Nix flake packaging [cavekit](https://github.com/JuliusBrussee/cavekit) for Nix-based development environments.

## Prerequisites

Nix with `nix-command` and `flakes` experimental features enabled.

## Development environment

```sh
nix develop
```

Enters the devShell with all tools (nixfmt, deadnix, typos, yamllint, editorconfig-checker, lefthook) and installs pre-commit hooks via lefthook.

## Build

```sh
nix build
```

Builds the cavekit plugin package. Output contains `plugin.json`, `FORMAT.md`, `commands/`, `skills/`, `.claude-plugin/`.

## Test

```sh
nix flake check
```

Runs all checks: flake structural validity and package output verification (confirms `plugin.json`, `FORMAT.md`, `commands/`, `skills/`, `.claude-plugin/` exist in build output).

For structural validity only (no build):

```sh
nix flake check --no-build
```

## Lint

Pre-commit hooks run automatically via lefthook on `git commit`. To run all hooks manually:

```sh
lefthook run pre-commit
```

Hooks enforce: nixfmt, statix, deadnix, nix-no-embedded-shell, yamllint, typos, editorconfig-checker, trailing-whitespace, missing-final-newline, git-conflict-markers, git-no-local-paths, nix-flake-check.

## File formatting

All files: LF line endings, UTF-8, 2-space indentation, final newline, no trailing whitespace (`.editorconfig`). Markdown: MD013 (line length) disabled. YAML: truthy check-keys and line-length disabled.

## Supported systems

`aarch64-darwin`, `x86_64-darwin`, `x86_64-linux`, `aarch64-linux`.
