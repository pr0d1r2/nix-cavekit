{
  description = "CHANGEME";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";

    set-and-setting.url = "github:pr0d1r2/set-and-setting";
    set-and-setting.inputs.nixpkgs-lock.follows = "nixpkgs-lock";
  };

  outputs =
    {
      self,
      nixpkgs,
      set-and-setting,
      ...
    }:
    let
      upstreamLib = set-and-setting.lib;
      consumerLib = upstreamLib // {
        checksFor = args:
          let
            fragmentsWithoutActions = builtins.filter (fragment: fragment != "actions") args.fragments;
            actionlint =
              let
                files = nixpkgs.lib.sources.sourceByRegex args.src [ "^\\.github/workflows/.*\\.(yml|yaml)$" ];
              in
              args.pkgs.runCommand "actionlint-check" { nativeBuildInputs = [ args.pkgs.findutils ]; } ''
                cd ${files}
                mapfile -t matches < <(find . -type f | sort)
                if [ ''${#matches[@]} -eq 0 ]; then
                  echo "actionlint: no matching files, nothing to check"
                  touch $out
                  exit 0
                fi
                ${nixpkgs.lib.getExe args.pkgs.actionlint} "''${matches[@]}"
                echo "actionlint: PASS (''${#matches[@]} files)"
                touch $out
              '';
          in
          (upstreamLib.checksFor (args // { fragments = fragmentsWithoutActions; })) // { inherit actionlint; };
      };
    in
    consumerLib.mkConsumerFlake {
      inherit self nixpkgs set-and-setting;
      lib = consumerLib;
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
}
