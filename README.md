# nix-cavekit

[![CI](https://github.com/pr0d1r2/nix-cavekit/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-cavekit/actions/workflows/ci.yml)

Nix package for [cavekit](https://github.com/JuliusBrussee/cavekit) — spec-driven development toolkit for AI coding agents.

## Usage

### As a flake input

```nix
{
  inputs.nix-cavekit = {
    url = "github:pr0d1r2/nix-cavekit";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # In devShell packages:
  nix-cavekit.packages.${system}.default
}
```

## Lefthook wrapper scripts

The development shell (`nix develop`) adds seven lefthook wrapper scripts
to your PATH. Each script is a self-contained
[`writeShellApplication`](https://nixos.org/manual/nixpkgs/stable/#trivial-builder-writeShellApplication)
wrapper with its runtime dependencies bundled — no extra packages needed.

| Script | Purpose | Runtime deps |
|---|---|---|
| `lefthook-git-conflict-markers` | Detect unresolved git conflict markers | gnugrep |
| `lefthook-git-no-local-paths` | Detect hardcoded local paths in staged files | gnugrep |
| `lefthook-markdownlint` | Lint Markdown files | markdownlint-cli |
| `lefthook-missing-final-newline` | Ensure files end with a newline | (none) |
| `lefthook-nix-no-embedded-shell` | Detect embedded shell code in `.nix` files | (none) |
| `lefthook-statix` | Run Nix static analysis | statix |
| `lefthook-trailing-whitespace` | Detect trailing whitespace | gnugrep |

These scripts are invoked automatically by lefthook on `git commit`
(configured in `lefthook.yml`). They can also be run manually:

```sh
lefthook run pre-commit
```

The CI devShell (`nix develop .#ci`) does not include these wrappers or
lefthook — CI runs the checks directly.

## License

MIT
