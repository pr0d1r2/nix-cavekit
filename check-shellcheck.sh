# shellcheck shell=bash
# Variables are provided by the nix build sandbox
# shellcheck disable=SC2154
shellcheck --shell=bash \
  "$devScript" \
  "$installScript" \
  "$checkPackageScript" \
  "$checkInstallScript" \
  "$checkShellcheckScript"
touch "$out"
