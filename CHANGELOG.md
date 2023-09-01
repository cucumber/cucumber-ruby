# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org).

This document is formatted according to the principles of [Keep A CHANGELOG](http://keepachangelog.com).

Please visit [cucumber/CONTRIBUTING.md](https://github.com/cucumber/cucumber/blob/master/CONTRIBUTING.md) for more info on how to contribute to Cucumber.

## [Unreleased]

### Fixed
- Cucumber was unable to generate the correct `VERSION` constant ([PR#1729](https://github.com/cucumber/cucumber-ruby/pull/1729) [luke-hill](https://github.com/luke-hill))

## [9.0.0] - 2023-08-31
### Added
- Add option `--retry-total` ([#1669](https://github.com/cucumber/cucumber-ruby/pull/1669))

### Changed
- Update dependency cucumber-gherkin to v26 ([#1688](https://github.com/cucumber/cucumber-ruby/pull/1688))
- Replace dependency [mime-types](https://rubygems.org/gems/mime-types)
with [mini_mime](https://rubygems.org/gems/mini_mime)
([#1695](https://github.com/cucumber/cucumber-ruby/pull/1695))

### Fixed
- Cucumber may raise NoMethodError when CUCUMBER_COLORS environment was set ([PR#1641](https://github.com/cucumber/cucumber-ruby/pull/1641/) [s2k](https://github.com/s2k))

### Removed
- Removed support for Ruby 2.6 and JRuby 9.3 ([PR#1699](https://github.com/cucumber/cucumber-ruby/pull/1699))

## [8.0.0] - 2022-05-19
### Added
- Add a _WARNING_ message when using a space-separated string with cucumber_opts
([PR#](https://github.com/cucumber/cucumber-ruby/pull/1624)
[Issue#1614](https://github.com/cucumber/cucumber-ruby/issues/1614))
- Add support for TruffleRuby
([PR#1612](https://github.com/cucumber/cucumber-ruby/pull/1612)
[gogainda](https://github.com/gogainda))
- Add support for named hooks
([PR#1636](https://github.com/cucumber/cucumber-ruby/pull/1636))

### Fixed
- Use `required_rubygems_version` instead of `rubygems_version`([PR#1629](https://github.com/cucumber/cucumber-ruby/pull/1629))
- Suppress RSspec deprecation warnings([PR#1631](https://github.com/cucumber/cucumber-ruby/pull/1631))

[Unreleased]: https://github.com/cucumber/cucumber-ruby/compare/v9.0.0...HEAD
[9.0.0]: https://github.com/cucumber/cucumber-ruby/compare/v8.0.0...v9.0.0
[8.0.0]: https://github.com/cucumber/cucumber-ruby/compare/v8.0.0.RC.1...v8.0.0
