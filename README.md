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

## License

MIT
