# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org).

This document is formatted according to the principles of [Keep A CHANGELOG](http://keepachangelog.com).

Please visit [cucumber/CONTRIBUTING.md](https://github.com/cucumber/cucumber/blob/master/CONTRIBUTING.md) for more info on how to contribute to Cucumber.

## [Unreleased]
### Added
- `ParameterType` message now is generated in an Envelope with an additional 6th property of `source_reference`
  (This is a `Location` message, of where the parameter types transformer is located) ([#1738](https://github.com/cucumber/cucumber-ruby/pull/1738) [luke-hill](https://github.com/luke-hill))

### Changed
- First couple of passes of tidying up approximately 40% of the manual fix cops
  ([#1739](https://github.com/cucumber/cucumber-ruby/pull/1739) [#1740](https://github.com/cucumber/cucumber-ruby/pull/1740) [#1741](https://github.com/cucumber/cucumber-ruby/pull/1741) [#1742](https://github.com/cucumber/cucumber-ruby/pull/1742) [luke-hill](https://github.com/luke-hill))
- Removed a bunch of example files / sample projects from ancient projects no longer viable
  ([#1740](https://github.com/cucumber/cucumber-ruby/pull/1740) [luke-hill](https://github.com/luke-hill))
- When a `testStepResult` is of type `FAILED` we now pass in a differently shaped message (Featuring a new exception propertu)
  ([#1738](https://github.com/cucumber/cucumber-ruby/pull/1738) [luke-hill](https://github.com/luke-hill))
- `#attach` now can take an optional filename parameter which will rename attachments like PDF's
  ([#1738](https://github.com/cucumber/cucumber-ruby/pull/1738) [luke-hill](https://github.com/luke-hill))

### Fixed
- Clear up a couple of tiny "nuances" that hide lots of issues when running local vs remote (Primarily CCK tests should always be runnable)
  ([#1738](https://github.com/cucumber/cucumber-ruby/pull/1738) [luke-hill](https://github.com/luke-hill))

### Removed
- Removed a variety of overrides / hacks for travis CI (No longer in use) ([#1738](https://github.com/cucumber/cucumber-ruby/pull/1738) [luke-hill](https://github.com/luke-hill))

## [9.0.2] - 2023-09-11
### Changed
- Began to tidy up (Cleared some AutoFix cops), and organise rubocop tech-debt in repo (This introduced new rubocop sub-gems) ([#1716](https://github.com/cucumber/cucumber-ruby/pull/1716) [luke-hill](https://github.com/luke-hill))
- Gem update. Update rubocop gems to latest and increase minimum version of some cucumber sub-gems ([#1732](https://github.com/cucumber/cucumber-ruby/pull/1732) [luke-hill](https://github.com/luke-hill))
- Rubocop update. Massively overhauled the cucumber style / rubocop expectations and began to tackle some long-standing tech-debt ([#1733](https://github.com/cucumber/cucumber-ruby/pull/1733) [luke-hill](https://github.com/luke-hill))
- First couple of passes of tidying up approximately 15% of the autofix cops
([#1736](https://github.com/cucumber/cucumber-ruby/pull/1736) [#1737](https://github.com/cucumber/cucumber-ruby/pull/1737) [luke-hill](https://github.com/luke-hill))

### Removed
- Removed a whole bunch of miscellaneous script files that are no longer used (Either in development or usage) ([#1721](https://github.com/cucumber/cucumber-ruby/pull/1721) [luke-hill](https://github.com/luke-hill))

## [9.0.1] - 2023-09-01
### Changed
- Update dependency of a few associated cucumber sub-gems ([#1715](https://github.com/cucumber/cucumber-ruby/pull/1715) [luke-hill](https://github.com/luke-hill))

### Fixed
- Cucumber was unable to generate the correct `VERSION` constant ([#1729](https://github.com/cucumber/cucumber-ruby/pull/1729) [luke-hill](https://github.com/luke-hill))

## [9.0.0] - 2023-08-31
### Added
- Add option `--retry-total` ([#1669](https://github.com/cucumber/cucumber-ruby/pull/1669))

### Changed
- Update dependency cucumber-gherkin to v26 ([#1688](https://github.com/cucumber/cucumber-ruby/pull/1688))
- Replace dependency [mime-types](https://rubygems.org/gems/mime-types)
with [mini_mime](https://rubygems.org/gems/mini_mime)
([#1695](https://github.com/cucumber/cucumber-ruby/pull/1695))

### Fixed
- Cucumber may raise NoMethodError when CUCUMBER_COLORS environment was set ([#1641](https://github.com/cucumber/cucumber-ruby/pull/1641/) [s2k](https://github.com/s2k))

### Removed
- Removed support for Ruby 2.6 and JRuby 9.3 ([#1699](https://github.com/cucumber/cucumber-ruby/pull/1699))

## [8.0.0] - 2022-05-19
### Added
- Add a _WARNING_ message when using a space-separated string with cucumber_opts
([#1624](https://github.com/cucumber/cucumber-ruby/pull/1624))
- Add support for TruffleRuby
([#1612](https://github.com/cucumber/cucumber-ruby/pull/1612)
[gogainda](https://github.com/gogainda))
- Add support for named hooks
([#1636](https://github.com/cucumber/cucumber-ruby/pull/1636))

### Fixed
- Use `required_rubygems_version` instead of `rubygems_version`([#1629](https://github.com/cucumber/cucumber-ruby/pull/1629))
- Suppress RSspec deprecation warnings([#1631](https://github.com/cucumber/cucumber-ruby/pull/1631))

## [8.0.0.RC.1] - 2022-01-19
### Changed
- Replace dependency [cucumber-create-meta](https://rubygems.org/gems/cucumber-create-meta)
with the new [cucumber-ci-environment](https://rubygems.org/gems/cucumber-ci-environment)
([#1601](https://github.com/cucumber/cucumber-ruby/pull/1601))
- In `DataTable#map_column`, Changed the `strict` argument into a keyword argument.
See upgrading notes for [8.0.0.md](upgrading_notes/8.0.0.md#upgrading-to-800)
([#1594](https://github.com/cucumber/cucumber-ruby/pull/1594))
- Added Ruby 3.1 ([#1607](https://github.com/cucumber/cucumber-ruby/pull/1607))

### Fixed
- Fix TestRunFinished success property in html formatter and all formatters
based on the messages: it now returns true if the run has passed
([#1606](https://github.com/cucumber/cucumber-ruby/pull/1606))
- Fix usage of namespaced modules across multiple scenarios
([#1603](https://github.com/cucumber/cucumber-ruby/pull/1603))
- Do not serialize Messages::Hook#tag_expression if it is empty
([#1579](https://github.com/cucumber/cucumber-ruby/pull/1579))
- JSON Formatter uses "pretty" output format
([#1580](https://github.com/cucumber/cucumber-ruby/pull/1580))
- Fixed JSON Formatter "end of background" detection
([#1580](https://github.com/cucumber/cucumber-ruby/pull/1580))
- Fixed JSON Formatter expansion of Scenario Outline templates in Doc Strings
([#1580](https://github.com/cucumber/cucumber-ruby/pull/1580))
- Removed usage of `eval` in `Cucumber::Term::ANSIColor` and `Cucumber::Formatter::ANSIColor`
([#1589](https://github.com/cucumber/cucumber-ruby/pull/1589))
- Fixed `DataTable#map_headers` when headers have the same prefix
([#1598](https://github.com/cucumber/cucumber-ruby/pull/1598))

### Removed
- `AfterConfiguration` has been removed. Please use `InstallPlugin` or `BeforeAll` instead.
See upgrading notes for [8.0.0.md](upgrading_notes/8.0.0.md#upgrading-to-800) to update your code accordingly.
([#1591](https://github.com/cucumber/cucumber-ruby/pull/1591))
- The built-in Wire protocol
The Wire protocol is still officially supported, but as an optional plugin rather
than a built-in feature. See upgrading notes for [8.0.0.md](upgrading_notes/8.0.0.md#upgrading-to-800) to update your code accordingly.
- Removed former unused `stdin` argument from `Cli::Main`. That may impact your code
if you use cucumber API `Cucumber::Cli::Main`. See upgrading notes for [8.0.0.md](upgrading_notes/8.0.0.md#upgrading-to-800).
([#1588](https://github.com/cucumber/cucumber-ruby/pull/1588))
- Removed `DataTable#map_column!` and `DataTable#map_headers!`.
Those methods were error-prone and planned to be removed a long time ago. You
can use the immutable versions instead: `DataTable#map_column` and
`DataTable#map_headers`.
([#1590](https://github.com/cucumber/cucumber-ruby/pull/1590))
- Removed support for Ruby 2.5 and JRuby 9.2.

[Unreleased]: https://github.com/cucumber/cucumber-ruby/compare/v9.0.2...HEAD
[9.0.2]: https://github.com/cucumber/cucumber-ruby/compare/v9.0.1...v9.0.2
[9.0.1]: https://github.com/cucumber/cucumber-ruby/compare/v9.0.0...v9.0.1
[9.0.0]: https://github.com/cucumber/cucumber-ruby/compare/v8.0.0...v9.0.0
[8.0.0]: https://github.com/cucumber/cucumber-ruby/compare/v8.0.0.RC.1...v8.0.0
[8.0.0.RC.1]: https://github.com/cucumber/cucumber-ruby/compare/v7.1.0...v8.0.0.RC.1
