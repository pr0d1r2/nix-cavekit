{ inputs }:
let
  inherit (inputs) self;
  inherit (inputs) nixpkgs;
  inherit (inputs) set-and-setting;
  inherit (inputs) cavekit-src;
in
{
  packages =
    nixpkgs.lib.genAttrs
      [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ]
      (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.runCommand "cavekit-plugin" { } ''
            cd ${cavekit-src}
            bash ${./install-plugin.sh}
          '';
          setting = (set-and-setting.lib.mkSetting { inherit pkgs; }).materialized;
        }
      );

  devShells =
    nixpkgs.lib.genAttrs
      [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ]
      (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        (set-and-setting.lib.mkDevShells {
          inherit pkgs;
          basePackages =
            (set-and-setting.lib.materializationFor {
              inherit pkgs;
              fragments = [
                "base"
                "actions"
                "nix"
                "shell"
                "ascii"
                "markdown"
                "yaml"
              ];
            }).packages;
          settingHook = ''
              ${self.packages.${system}.setting}/bin/sync-setting .
            _assemble_out="$(mktemp -d)"
              FRAGMENTS="base actions nix shell ascii markdown yaml" \
              out="$_assemble_out" \
              FRAGMENTS_DIR="${set-and-setting}/setting/integrations/lefthook" \
              bash "${set-and-setting}/setting/lib/assemble-lefthook.sh"
            cp -f "$_assemble_out/lefthook.yml" lefthook.yml
            rm -rf "$_assemble_out"
          '';
        })
        // {
          # Compatibility output retained for consumers of the pre-migration flake.
          ci = pkgs.mkShell {
            packages = with pkgs; [
              coreutils
              deadnix
              git
              nix
              nixfmt
              shellcheck
              shfmt
              typos
              yamllint
            ];
          };
        }
      );

  checks = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ] (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};

      sys = pkgs.stdenv.hostPlatform.system;
      standardChecks = set-and-setting.lib.checksFor {
        inherit pkgs;
        fragments = [
          "base"
          "actions"
          "nix"
          "shell"
          "ascii"
          "markdown"
          "yaml"
        ];
        src = ./.;
      };
    in
    standardChecks
    // rec {
      dep-graph = set-and-setting.lib.mkDepGraphCheck {
        inherit pkgs;
        projectRoot = ./.;
      };
      package = pkgs.runCommand "check-package" {
        cavekitPkg = self.packages.${sys}.default;
      } (builtins.readFile ./check-package.sh);
      package-files = package;
      install-validation = pkgs.runCommand "check-install-validation" {
        installScript = builtins.readFile ./install-plugin.sh;
      } (builtins.readFile ./check-install-validation.sh);
      shellcheck-scripts = standardChecks.shellcheck;
      shfmt-format = standardChecks.shfmt;
      default = pkgs.runCommand "checks" { } "touch $out";
    }
  );

  apps = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ] (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};

      mat = set-and-setting.lib.materializationFor {
        inherit pkgs;
        fragments = [
          "base"
          "actions"
          "nix"
          "shell"
          "ascii"
          "markdown"
          "yaml"
        ];
      };
    in
    {
      confirm = {
        type = "app";
        program = "${
          pkgs.writeShellApplication {
            name = "confirm";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.diffutils
              pkgs.findutils
              pkgs.gawk
              pkgs.git
              pkgs.gnugrep
            ]
            ++ mat.packages;
            text =
              builtins.replaceStrings
                [
                  "@FRAGMENTS_DIR@"
                  "@ASSEMBLE_SCRIPT@"
                  "@DETECT_SCRIPT@"
                  "@SETTING_SRC@"
                  "@CONFIRM_SCRIPT@"
                  "@CONFIRM_REV@"
                ]
                [
                  "${set-and-setting}/setting/integrations/lefthook"
                  "${set-and-setting}/setting/lib/assemble-lefthook.sh"
                  "${set-and-setting}/setting/lib/detect-fragments.sh"
                  "${self.packages.${pkgs.stdenv.hostPlatform.system}.setting}"
                  "${set-and-setting}/lib/confirm.sh"
                  (set-and-setting.rev or "unknown")
                ]
                (builtins.readFile ./confirm.sh);
          }
        }/bin/confirm";
      };
    }
  );
}
