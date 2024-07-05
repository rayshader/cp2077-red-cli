# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
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
[Unreleased]: https://github.com/rayshader/cp2077-red-cli/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/rayshader/cp2077-red-cli/releases/tag/v0.1.0
