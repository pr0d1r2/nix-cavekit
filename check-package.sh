# shellcheck shell=bash
# $cavekitPkg and $out are provided by the nix build sandbox
# shellcheck disable=SC2154
test -f "$cavekitPkg/plugin.json"
test -f "$cavekitPkg/FORMAT.md"
test -d "$cavekitPkg/commands"
test -d "$cavekitPkg/skills"
test -d "$cavekitPkg/.claude-plugin"
touch "$out"
