# shellcheck shell=bash
# $out is provided by the nix build sandbox
# shellcheck disable=SC2154
mkdir -p "$out/commands" "$out/skills"
cp plugin.json "$out/"
cp FORMAT.md "$out/"
cp -r commands "$out/"
cp -r skills "$out/"
cp -r .claude-plugin "$out/"
