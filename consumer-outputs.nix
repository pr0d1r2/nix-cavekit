{ inputs }:
let
  inherit (inputs) self nixpkgs set-and-setting;
  upstreamLib = set-and-setting.lib;
  consumerLib = upstreamLib // {
    checksFor =
      args:
      let
        fragmentsWithoutActions = builtins.filter (fragment: fragment != "actions") args.fragments;
        actionlint =
          let
            files = nixpkgs.lib.sources.sourceByRegex args.src [ "^\\.github/workflows/.*\\.(yml|yaml)$" ];
          in
          args.pkgs.runCommand "actionlint-check" { } (
            builtins.replaceStrings
              [ "@FILES@" "@ACTIONLINT@" ]
              [ "${files}" "${nixpkgs.lib.getExe args.pkgs.actionlint}" ]
              (builtins.readFile ./actionlint-check.sh)
          );
      in
      (upstreamLib.checksFor (args // { fragments = fragmentsWithoutActions; }))
      // {
        inherit actionlint;
      };
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
}
