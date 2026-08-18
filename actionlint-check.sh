#!/usr/bin/env bash
# $out is provided by the Nix build sandbox.
# shellcheck disable=SC2154

cd @FILES@ || exit 1
mapfile -t matches < <(find . -type f | sort)
if [ "${#matches[@]}" -eq 0 ]; then
  echo "actionlint: no matching files, nothing to check"
  touch "$out"
  exit 0
fi
@ACTIONLINT@ "${matches[@]}"
echo "actionlint: PASS (${#matches[@]} files)"
touch "$out"
