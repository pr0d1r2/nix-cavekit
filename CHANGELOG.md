# Changelog

All notable changes to this project are documented here.

## Unreleased

- Refresh the `nixpkgs-lock` input (nixpkgs `ac588ef`). ruby in the locked
  nixpkgs is still 3.4.11 (CVE-2026-97229, fixed in 3.4.12); the fix waits on
  pr0d1r2/nixpkgs-lock#94. ruby is not in this package's closure. Wait for
  that pin update to land before running `nix flake update nixpkgs-lock`;
  the nixpkgs backport alone does not move the pin.

- Build against the current set-and-setting `mkConsumerFlake`, which no longer
  takes a `lib` override. The standard `actions` fragment now provides
  `actionlint`, so the local actionlint check is gone.

- Restore the `cavekit` and `default` packages, lost in the move to the
  referenced standard, so consumers can install the plugin from this flake again.
