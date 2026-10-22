{ inputs }:
let
  inherit (inputs)
    self
    nixpkgs
    set-and-setting
    cavekit-src
    ;
in
set-and-setting.lib.mkConsumerFlake {
  inherit self nixpkgs set-and-setting;
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
  extraPackages =
    pkgs:
    let
      cavekit = pkgs.runCommand "cavekit-plugin" { } ''
        cd ${cavekit-src}
        bash ${./install-plugin.sh}
      '';
    in
    {
      inherit cavekit;
      default = cavekit;
    };
  extraChecks = pkgs: {
    cavekit-package =
      assert builtins.hasAttr "default" self.packages.${pkgs.stdenv.hostPlatform.system};
      assert builtins.hasAttr "cavekit" self.packages.${pkgs.stdenv.hostPlatform.system};
      pkgs.runCommand "cavekit-package-output-check" { } "touch $out";
  };
}
