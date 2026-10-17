# Changelog

All notable changes to this project are documented here.

## Unreleased

- Build against the current set-and-setting `mkConsumerFlake`, which no longer
  takes a `lib` override. The standard `actions` fragment now provides
  `actionlint`, so the local actionlint check is gone.

- Restore the `cavekit` and `default` packages, lost in the move to the
  referenced standard, so consumers can install the plugin from this flake again.
