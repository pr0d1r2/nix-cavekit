# shellcheck shell=bash
# Variables are provided by the nix build sandbox
# shellcheck disable=SC2154
shfmt -d -i 2 -ci \
  "$devScript" \
  "$installScript" \
  "$checkPackageScript" \
  "$checkInstallScript" \
  "$checkShellcheckScript" \
  "$checkShfmtScript"
touch "$out"
