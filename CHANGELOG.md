# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Fixed
- flags `--debug` / `--release` are now applied as expected with `bundle` and
  `install` commands.

### Added
- support to install / pack CET scripts using `scripts.cet` options in `red.config.json`.

------------------------

## [0.2.2] - 2024-07-19
### Fixed
- silently fail to install plugin while the game is running (issue #2).

### Added
- environment variable `REDCLI_GAME` to prevent commiting user's game path in
  `red.config.json` when versioning (issue #1).

------------------------

## [0.2.1] - 2024-07-14
### Fixed
- support conditional annotation on import statement.

------------------------

## [0.2.0] - 2024-07-05
### Fixed
- crash with `install` command when "plugin" option is not provided. Option
  must be optional as it is only useful for RED4ext plugin.

### Changed
- `install` command is now using `debug` mode by default (was `release` mode).

------------------------

## [0.1.0] - 2024-06-23
### Added
- command to bundle scripts (merge per module).
- command to install scripts in game's directory.
- command to pack scripts in an archive, ready to release.
- support Redscript scripts.
- support RED4ext plugin.
- optionally copy LICENSE file in `r6\scripts\<Mod>` in `release` mode.

<!-- Table of releases -->
[Unreleased]: https://github.com/rayshader/cp2077-red-cli/compare/v0.2.2...HEAD
[0.2.2]: https://github.com/rayshader/cp2077-red-cli/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/rayshader/cp2077-red-cli/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/rayshader/cp2077-red-cli/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/rayshader/cp2077-red-cli/releases/tag/v0.1.0
