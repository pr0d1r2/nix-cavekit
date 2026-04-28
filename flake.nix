{
  description = "Nix package for cavekit — spec-driven development toolkit";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    cavekit-src = {
      url = "github:JuliusBrussee/cavekit";
      flake = false;
    };
    nix-lefthook-git-conflict-markers = {
      url = "github:pr0d1r2/nix-lefthook-git-conflict-markers";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-git-no-local-paths = {
      url = "github:pr0d1r2/nix-lefthook-git-no-local-paths";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-missing-final-newline = {
      url = "github:pr0d1r2/nix-lefthook-missing-final-newline";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-nix-no-embedded-shell = {
      url = "github:pr0d1r2/nix-lefthook-nix-no-embedded-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-trailing-whitespace = {
      url = "github:pr0d1r2/nix-lefthook-trailing-whitespace";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-statix = {
      url = "github:pr0d1r2/nix-lefthook-statix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-lefthook-git-conflict-markers.follows = "nix-lefthook-git-conflict-markers";
        nix-lefthook-git-no-local-paths.follows = "nix-lefthook-git-no-local-paths";
        nix-lefthook-missing-final-newline.follows = "nix-lefthook-missing-final-newline";
        nix-lefthook-trailing-whitespace.follows = "nix-lefthook-trailing-whitespace";
      };
    };
  };

  outputs =
    {
      nixpkgs,
      cavekit-src,
      nix-lefthook-git-conflict-markers,
      nix-lefthook-git-no-local-paths,
      nix-lefthook-missing-final-newline,
      nix-lefthook-nix-no-embedded-shell,
      nix-lefthook-trailing-whitespace,
      nix-lefthook-statix,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.stdenvNoCC.mkDerivation {
          name = "cavekit-plugin";
          src = cavekit-src;
          dontBuild = true;
          installPhase = builtins.readFile ./install-plugin.sh;
        };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            nix-lefthook-git-conflict-markers.packages.${pkgs.stdenv.hostPlatform.system}.default
            nix-lefthook-git-no-local-paths.packages.${pkgs.stdenv.hostPlatform.system}.default
            nix-lefthook-missing-final-newline.packages.${pkgs.stdenv.hostPlatform.system}.default
            nix-lefthook-nix-no-embedded-shell.packages.${pkgs.stdenv.hostPlatform.system}.default
            nix-lefthook-trailing-whitespace.packages.${pkgs.stdenv.hostPlatform.system}.default
            nix-lefthook-statix.packages.${pkgs.stdenv.hostPlatform.system}.default
            pkgs.coreutils
            pkgs.deadnix
            pkgs.editorconfig-checker
            pkgs.git
            pkgs.lefthook
            pkgs.nix
            pkgs.nixfmt
            pkgs.typos
            pkgs.yamllint
          ];
          shellHook = builtins.readFile ./dev.sh;
        };
      });
    };
}
