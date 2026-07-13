{
  description = "Nix package for cavekit — spec-driven development toolkit";

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";
    cavekit-src = {
      url = "github:JuliusBrussee/cavekit";
      flake = false;
    };
    nix-lefthook-editorconfig-checker-src = {
      url = "github:pr0d1r2/nix-lefthook-editorconfig-checker";
      flake = false;
    };
    nix-lefthook-git-conflict-markers-src = {
      url = "github:pr0d1r2/nix-lefthook-git-conflict-markers";
      flake = false;
    };
    nix-lefthook-git-no-local-paths-src = {
      url = "github:pr0d1r2/nix-lefthook-git-no-local-paths";
      flake = false;
    };
    nix-lefthook-markdownlint-src = {
      url = "github:pr0d1r2/nix-lefthook-markdownlint";
      flake = false;
    };
    nix-lefthook-missing-final-newline-src = {
      url = "github:pr0d1r2/nix-lefthook-missing-final-newline";
      flake = false;
    };
    nix-lefthook-deadnix-src = {
      url = "github:pr0d1r2/nix-lefthook-deadnix";
      flake = false;
    };
    nix-lefthook-nixfmt-src = {
      url = "github:pr0d1r2/nix-lefthook-nixfmt";
      flake = false;
    };
    nix-lefthook-nix-no-embedded-shell-src = {
      url = "github:pr0d1r2/nix-lefthook-nix-no-embedded-shell";
      flake = false;
    };
    nix-lefthook-shellcheck-src = {
      url = "github:pr0d1r2/nix-lefthook-shellcheck";
      flake = false;
    };
    nix-lefthook-statix-src = {
      url = "github:pr0d1r2/nix-lefthook-statix";
      flake = false;
    };
    nix-lefthook-trailing-whitespace-src = {
      url = "github:pr0d1r2/nix-lefthook-trailing-whitespace";
      flake = false;
    };
    nix-lefthook-typos-src = {
      url = "github:pr0d1r2/nix-lefthook-typos";
      flake = false;
    };
    nix-lefthook-yamllint-src = {
      url = "github:pr0d1r2/nix-lefthook-yamllint";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      cavekit-src,
      nix-lefthook-deadnix-src,
      nix-lefthook-editorconfig-checker-src,
      nix-lefthook-git-conflict-markers-src,
      nix-lefthook-git-no-local-paths-src,
      nix-lefthook-markdownlint-src,
      nix-lefthook-missing-final-newline-src,
      nix-lefthook-nixfmt-src,
      nix-lefthook-nix-no-embedded-shell-src,
      nix-lefthook-shellcheck-src,
      nix-lefthook-statix-src,
      nix-lefthook-trailing-whitespace-src,
      nix-lefthook-typos-src,
      nix-lefthook-yamllint-src,
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

      mkCavekitPlugin =
        pkgs:
        pkgs.stdenvNoCC.mkDerivation {
          name = "cavekit-plugin";
          src = cavekit-src;
          dontBuild = true;
          installPhase = builtins.readFile ./install-plugin.sh;
        };

      lefthookWrappersFor =
        pkgs:
        let
          wrap =
            name: src: extra:
            pkgs.writeShellApplication (
              {
                inherit name;
                text = builtins.readFile "${src}/${name}.sh";
              }
              // extra
            );
        in
        [
          (wrap "lefthook-deadnix" nix-lefthook-deadnix-src {
            runtimeInputs = [ pkgs.deadnix ];
          })
          (wrap "lefthook-editorconfig-checker" nix-lefthook-editorconfig-checker-src {
            runtimeInputs = [ pkgs.editorconfig-checker ];
          })
          (wrap "lefthook-git-conflict-markers" nix-lefthook-git-conflict-markers-src {
            runtimeInputs = [ pkgs.gnugrep ];
          })
          (wrap "lefthook-git-no-local-paths" nix-lefthook-git-no-local-paths-src {
            runtimeInputs = [ pkgs.gnugrep ];
          })
          (wrap "lefthook-markdownlint" nix-lefthook-markdownlint-src {
            runtimeInputs = [ pkgs.markdownlint-cli ];
          })
          (wrap "lefthook-missing-final-newline" nix-lefthook-missing-final-newline-src { })
          (wrap "lefthook-nixfmt" nix-lefthook-nixfmt-src {
            runtimeInputs = [ pkgs.nixfmt ];
          })
          (pkgs.writeShellApplication {
            name = "lefthook-nix-no-embedded-shell";
            text = ''
              SCANNER="${nix-lefthook-nix-no-embedded-shell-src}/scan-nix-no-embedded-shell.sh"
            ''
            + builtins.readFile "${nix-lefthook-nix-no-embedded-shell-src}/lefthook-nix-no-embedded-shell.sh";
          })
          (wrap "lefthook-shellcheck" nix-lefthook-shellcheck-src {
            runtimeInputs = [ pkgs.shellcheck ];
          })
          (wrap "lefthook-statix" nix-lefthook-statix-src {
            runtimeInputs = [ pkgs.statix ];
          })
          (wrap "lefthook-trailing-whitespace" nix-lefthook-trailing-whitespace-src {
            runtimeInputs = [ pkgs.gnugrep ];
          })
          (wrap "lefthook-typos" nix-lefthook-typos-src {
            runtimeInputs = [ pkgs.typos ];
          })
          (wrap "lefthook-yamllint" nix-lefthook-yamllint-src {
            runtimeInputs = [ pkgs.yamllint ];
          })
        ];
    in
    {
      packages = forAllSystems (pkgs: {
        default = mkCavekitPlugin pkgs;
      });

      checks = forAllSystems (pkgs: {
        package-files = pkgs.runCommand "cavekit-plugin-check" {
          cavekitPkg = mkCavekitPlugin pkgs;
        } (builtins.readFile ./check-package.sh);
        install-validation = pkgs.runCommand "install-validation-check" {
          installScript = builtins.readFile ./install-plugin.sh;
        } (builtins.readFile ./check-install-validation.sh);
        shellcheck-scripts = pkgs.runCommand "shellcheck-scripts-check" {
          nativeBuildInputs = [ pkgs.shellcheck ];
          devScript = ./dev.sh;
          installScript = ./install-plugin.sh;
          checkPackageScript = ./check-package.sh;
          checkInstallScript = ./check-install-validation.sh;
          checkShellcheckScript = ./check-shellcheck.sh;
        } (builtins.readFile ./check-shellcheck.sh);
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.coreutils
            pkgs.deadnix
            pkgs.editorconfig-checker
            pkgs.git
            pkgs.lefthook
            pkgs.nix
            pkgs.nixfmt
            pkgs.shellcheck
            pkgs.typos
            pkgs.yamllint
          ]
          ++ (lefthookWrappersFor pkgs);
          shellHook = builtins.readFile ./dev.sh;
        };
        ci = pkgs.mkShell {
          packages = [
            pkgs.coreutils
            pkgs.deadnix
            pkgs.git
            pkgs.nix
            pkgs.nixfmt
            pkgs.shellcheck
            pkgs.typos
            pkgs.yamllint
          ];
        };
      });
    };
}
