# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org).

This document is formatted according to the principles of [Keep A CHANGELOG](http://keepachangelog.com).

Please visit [cucumber/CONTRIBUTING.md](https://github.com/cucumber/cucumber/blob/master/CONTRIBUTING.md) for more info on how to contribute to Cucumber.

## [Unreleased]

## [9.0.1] - 2023-09-01
### Changed
- Update dependency of a few associated cucumber sub-gems ([#1715](https://github.com/cucumber/cucumber-ruby/pull/1715) [luke-hill](https://github.com/luke-hill))

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

## [8.0.0.RC.1]
### Changed
- Replace dependency [cucumber-create-meta](https://rubygems.org/gems/cucumber-create-meta)
  with the new [cucumber-ci-environment](https://rubygems.org/gems/cucumber-ci-environment)
  ([PR#1601](https://github.com/cucumber/cucumber-ruby/pull/1601))
- In `DataTable#map_column`, Changed the `strict` argument into a keyword argument.
  See [UPGRADING.md](./UPGRADING.md#upgrading-to-800).
  ([PR#1594](https://github.com/cucumber/cucumber-ruby/pull/1594)
  [Issue#1592](https://github.com/cucumber/cucumber-ruby/issues/1592))
- Added Ruby 3.1
  ([PR#1607](https://github.com/cucumber/cucumber-ruby/pull/1607))

### Fixed
- Fix TestRunFinished success property in html formatter and all formatters
  based on the messages: it now returns true if the run has passed
  ([PR#1606](https://github.com/cucumber/cucumber-ruby/pull/1606)
  [Issue#1604](https://github.com/cucumber/cucumber-ruby/issues/1604))
- Fix usage of namespaced modules across multiple scenarios
  ([PR#1603](https://github.com/cucumber/cucumber-ruby/pull/1603)
  [Issue#1595](https://github.com/cucumber/cucumber-ruby/issues/1595))
- Do not serialize Messages::Hook#tag_expression if it is empty.
  ([PR#1579](https://github.com/cucumber/cucumber-ruby/pull/1579))
- JSON Formatter uses "pretty" output format
  ([PR#1580](https://github.com/cucumber/cucumber-ruby/pull/1580))
- Fixed JSON Formatter "end of background" detection.
  ([PR#1580](https://github.com/cucumber/cucumber-ruby/pull/1580))
- Fixed JSON Formatter expansion of Scenario Outline templates in Doc Strings.
  ([PR#1580](https://github.com/cucumber/cucumber-ruby/pull/1580))
- Removed usage of `eval` in `Cucumber::Term::ANSIColor` and `Cucumber::Formatter::ANSIColor`.
  ([PR#1589](https://github.com/cucumber/cucumber-ruby/pull/1589)
  [Issue#1583](https://github.com/cucumber/cucumber-ruby/issues/1583))
- Fixed `DataTable#map_headers` when headers have the same prefix.
  ([PR#1598](https://github.com/cucumber/cucumber-ruby/pull/1598)
  [Issue#1450](https://github.com/cucumber/cucumber-ruby/issues/1450))

### Removed
- `AfterConfiguration` has been removed. Please use `InstallPlugin` or `BeforeAll` instead.
  See the [UPGRADING.md](./UPGRADING.md#upgrading-to-800) to update your code accordingly.
  ([PR#1591](https://github.com/cucumber/cucumber-ruby/pull/1591))
- The built-in Wire protocol
  The Wire protocol is still officially supported, but as an optional plugin rather
  than a built-in feature. See the
  [UPGRADING.md](./UPGRADING.md#upgrading-to-800)
  to update your code accordingly.
- Removed former unused `stdin` argument from `Cli::Main`. That may impact your code
  if you use cucumber API `Cucumber::Cli::Main`. See [UPGRADING.md](./UPGRADING.md#upgrading-to-800).
  ([PR#1588](https://github.com/cucumber/cucumber-ruby/pull/1588)
  [Issue#1581](https://github.com/cucumber/cucumber-ruby/issues/1581))
- Removed `DataTable#map_column!` and `DataTable#map_headers!`.
  Those methods were error-prone and planned to be removed a long time ago. You
  can use the immutable versions instead: `DataTable#map_column` and
  `DataTable#map_headers`.
  ([PR#1590](https://github.com/cucumber/cucumber-ruby/pull/1590)
  [Issue#1584](https://github.com/cucumber/cucumber-ruby/issues/1584))
- Removed support for Ruby 2.5 and JRuby 9.2.

[Unreleased]: https://github.com/cucumber/cucumber-ruby/compare/v9.0.1...HEAD
[9.0.1]: https://github.com/cucumber/cucumber-ruby/compare/v9.0.0...v9.0.1
[9.0.0]: https://github.com/cucumber/cucumber-ruby/compare/v8.0.0...v9.0.0
[8.0.0]: https://github.com/cucumber/cucumber-ruby/compare/v8.0.0.RC.1...v8.0.0
[8.0.0.RC.1]: https://github.com/cucumber/cucumber-ruby/compare/v7.1.0...v8.0.0.RC.1