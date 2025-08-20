# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog v1](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning v2](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [1.0.3] - 2025-08-20
- TAG: [v1.0.3][1.0.3t]
- COVERAGE: 100.00% -- 132/132 lines in 7 files
- BRANCH COVERAGE: 100.00% -- 26/26 branches in 7 files
- 100% documented
### Added
- Tests: cover both branches of ExampleDecorator's global_timecop_method and global_timecop_time to ensure behavior when global time is configured vs. disabled, and when skipped via metadata.
- more documentation on how to support the project
- (dev) enforce gitmoji commit messages (first char is Gitmoji)
- (dev) support for appending a custom footer to commits via
    - .git-hooks/prepare-commit-msg
    - bin/prepare-commit-msg
### Changed
- (dev) Upgraded to Galtzo FLOSS Rakefile v1.0.11
### Fixed
- gemspec attributes (remove duplicates)

## [1.0.2] - 2025-08-18
- TAG: [v1.0.2][1.0.2t]
- COVERAGE: 100.00% -- 132/132 lines in 7 files
- BRANCH COVERAGE: 92.31% -- 24/26 branches in 7 files
- 100% documented
### Added
- improved CI
### Changed
- upgraded to Galtzo FLOSS Rakefile v1.0.9
### Fixed
- documentation, changelog
- fix ancient bin/console script

## [1.0.1] - 2025-08-17
- TAG: [v1.0.1][1.0.1t]
- COVERAGE: 100.00% -- 132/132 lines in 7 files
- BRANCH COVERAGE:  92.31% -- 24/26 branches in 7 files
- 100% documented
### Removed
- refactored to remove dependency on activesupport

## [1.0.0] - 2025-08-17
- TAG: [v1.0.0][1.0.0t]
- COVERAGE: 100.00% -- 131/131 lines in 7 files
- BRANCH COVERAGE:  92.31% -- 24/26 branches in 7 files
- 100% documented
### Added
- Initial release to rubygems (8 years late!)

[Unreleased]: https://gitlab.com/galtzo-floss/timecop-rspec/-/compare/v1.0.3...main
[1.0.3]: https://gitlab.com/galtzo-floss/timecop-rspec/-/compare/v1.0.2...v1.0.3
[1.0.3t]: https://gitlab.com/galtzo-floss/timecop-rspec/-/tags/v1.0.3
[1.0.2]: https://gitlab.com/galtzo-floss/timecop-rspec/-/compare/v1.0.1...v1.0.2
[1.0.2t]: https://gitlab.com/galtzo-floss/timecop-rspec/-/tags/v1.0.2
[1.0.1]: https://gitlab.com/galtzo-floss/timecop-rspec/-/compare/v1.0.0...v1.0.1
[1.0.1t]: https://gitlab.com/galtzo-floss/timecop-rspec/-/tags/v1.0.1
[1.0.0]: https://gitlab.com/galtzo-floss/timecop-rspec/-/compare/13c672f32c466824277d04c932e3244deb6451ea...v1.0.0
[1.0.0t]: https://gitlab.com/galtzo-floss/timecop-rspec/-/tags/v1.0.0
