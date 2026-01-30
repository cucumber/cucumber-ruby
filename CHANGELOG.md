# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org).

This document is formatted according to the principles of [Keep A CHANGELOG](http://keepachangelog.com).

Please visit [cucumber/CONTRIBUTING.md](https://github.com/cucumber/cucumber/blob/master/CONTRIBUTING.md) for more info on how to contribute to Cucumber.

## [Unreleased]
### Added
- A first initial iteration of the new `cucumber-query` structure ([#1801](https://github.com/cucumber/cucumber-ruby/pull/1801) [luke-hill](https://github.com/luke-hill))

> This is currently not consumed anywhere, but will become the building blocks for the future of cucumber formatters
> which we hope to begin migrating to in the start of 2026

### Fixed
- Fix crash when `Cucumber::Messages::Group#children` is `nil`

## [10.2.0] - 2025-12-10
### Changed
- Permit the latest version of the `cucumber-html-formatter` (v22.0.0+)
- Permit `cucumber-expressions` up to v19

## [10.1.1] - 2025-10-08
### Changed
- Internal refactors to CCK testing code to better check that the message formatter responses are as expected
- Simplify `#attach` by better checking the different use cases (base64 vs file path)

### Fixed
- Prevent messages (And any consuming formatters), from not handling unknown (base64), media types ([#1796](https://github.com/cucumber/cucumber-ruby/pull/1796) [luke-hill](https://github.com/luke-hill))

## [10.1.0] - 2025-08-20
### Changed
- Updated `cucumber-compatibility-kit` to v20
- Optimised `compatibility` tests (That use the CCK), so that tests run slightly more optimal (Creating less empty arrays)

### Fixed
- Fixed an issue where the html-formatter wasn't respecting the new structure for `StackTrace` cucumber messages ([#1790](https://github.com/cucumber/cucumber-ruby/pull/1790) [luke-hill](https://github.com/luke-hill))

## [10.0.0] - 2025-06-11
### Changed
- Added dependencies that will no longer be part of the ruby stdlib ([jeromeag](https://github.com/jerome))
- NB: This change has also facilitated a tweak to some output messages to include new fields such as `testRunStartedId`
for full changes and expectations of what will be new check the [messages](https://github.com/cucumber/messages/blob/main/CHANGELOG.md#2700---2024-10-26)
([luke-hill](https://github.com/luke-hill))
- Updated `cucumber-compatibility-kit` to v18
- Changed compatibility testing to fully lean on external assets instead of duplicating them ([luke-hill](https://github.com/luke-hill))
- Permit usage of latest versions of all cucumber internal gems
- The auto-generation of all placeholder `pending` steps has been refactored (_There should be no visible changes
but the code is now refactored to work using newer ruby standards_)
- The `#text?` method for checking Differences in multi-line text is now deprecated (Users
should lean on an appropriate testing library for this)
- `Cucumber.use_legacy_autoloader` that was intended as a stop-gap for v4/v5 is now deprecated (People
that need to rely on procedural loading / reloading of files should use method invocations) ([luke-hill](https://github.com/luke-hill))
- The backtrace filtering logic has been changed (_There should be no visible changes but the code is now
refactored to use newer, less procedural ruby_)

### Fixed
- Fixed an issue where a change to one example in compatibility testing wasn't fully adhered to ([luke-hill](https://github.com/luke-hill))
- Fixed Ruby 3.4+ issue where error backtraces weren't being formatted. ([#1771](https://github.com/cucumber/cucumber-ruby/pull/1771) [orien](https://github.com/orien))
- Fix some problematic specs that were leaking state and showcasing an issue on JRuby ([#1783](https://github.com/cucumber/cucumber-ruby/pull/1783) [luke-hill](https://github.com/luke-hill))

### Removed
- `StepDefinitionLight` associated methods. The class itself is present but deprecated
- `Webrick` Proc handling aliases that were long redundant
- Associated legacy scripts for updating dependencies that are no longer used
- Tag Expressions using legacy syntax that were handled / sanitized are no longer done so
(This applies to both regular usage and internal testing)
- Removed support for Ruby 2.7 and 3.0 (Minimum ruby is now 3.1) ([luke-hill](https://github.com/luke-hill))
- Unindentation support for snippet generator / tests (Heredocs are much better now) ([luke-hill](https://github.com/luke-hill))

## [9.2.1] - 2025-01-12
### Fixed
- Fixed an issue for Ruby 3.4+ where a default hash instantiation was being picked up as keyword arguments ([Jon Rowe](https://github.com/JonRowe))

## [9.2.0] - 2024-03-19
### Changed
- Updated cucumber dependencies (Specifically cucumber-core) ([luke-hill](https://github.com/luke-hill))
- Uncoupled a lot of dual-responsibility complexity in HTTP classes (Specifically the builders/parsers)
([#1752](https://github.com/cucumber/cucumber-ruby/pull/1750) [luke-hill](https://github.com/luke-hill))

### Removed
- Some legacy JRuby local testing profiles are now removed ([luke-hill](https://github.com/luke-hill))

## [9.1.2] - 2024-01-23
### Changed
- Moved all CCK step definition/miscellaneous file logic from CCK gem to this repo.
All logic contained in [compatibility](./compatibility) ([luke-hill](https://github.com/luke-hill))
- Cleared up a few Layout/Linting cop offenses ([#1750](https://github.com/cucumber/cucumber-ruby/pull/1750) [luke-hill](https://github.com/luke-hill))

### Fixed
- Fix a situation whereby the step definition message will omit the parameter-type name when it cannot be inferred
(This fixes an issue in cucumber-wire when passing legacy steps down the wire)
([#1746](https://github.com/cucumber/cucumber-ruby/pull/1746) [luke-hill](https://github.com/luke-hill))

## [9.1.1] - 2024-01-04
### Changed
- Updated dependencies to slightly more permissive / up to date versions ([luke-hill](https://github.com/luke-hill))
- Fixed most of the `Layout` cop offenses ([luke-hill](https://github.com/luke-hill))

### Removed
- The sample sinatra tests are no longer used in internal testing (This removes a bunch of superfluous dev gems) ([#1743](https://github.com/cucumber/cucumber-ruby/pull/1743) [luke-hill](https://github.com/luke-hill))
- Removed all references to autotest as this is an ancient plugin that is not correctly integrated

## [9.1.0] - 2023-11-14
### Changed
- First iteration to tidy up approximately 40% of the manual fix cops
([#1739](https://github.com/cucumber/cucumber-ruby/pull/1739) [#1740](https://github.com/cucumber/cucumber-ruby/pull/1740) [#1741](https://github.com/cucumber/cucumber-ruby/pull/1741) [#1742](https://github.com/cucumber/cucumber-ruby/pull/1742) [luke-hill](https://github.com/luke-hill))
- Removed a bunch of example files / sample projects from ancient projects no longer viable
([#1740](https://github.com/cucumber/cucumber-ruby/pull/1740) [luke-hill](https://github.com/luke-hill))
- When a `testStepResult` is of type `FAILED` we now pass in a new (Exception), message property
([#1738](https://github.com/cucumber/cucumber-ruby/pull/1738) [luke-hill](https://github.com/luke-hill))
- `ParameterType` message now contains a new (sourceReference), property
(This contains a uri string and a `Location` message -> for where the ParameterType `transformer` is located) ([#1738](https://github.com/cucumber/cucumber-ruby/pull/1738) [luke-hill](https://github.com/luke-hill))
- `#attach` now can take an optional filename parameter which will rename attachments like PDF's
([#1738](https://github.com/cucumber/cucumber-ruby/pull/1738) [luke-hill](https://github.com/luke-hill))

### Fixed
- Clear up a couple of tiny "nuances" that hide lots of issues when running local vs remote (Primarily CCK tests should always be runnable)
([#1738](https://github.com/cucumber/cucumber-ruby/pull/1738) [luke-hill](https://github.com/luke-hill))

### Removed
- Removed a variety of overrides / hacks for travis CI (No longer in use) ([#1738](https://github.com/cucumber/cucumber-ruby/pull/1738) [luke-hill](https://github.com/luke-hill))
- Removed some legacy rspec pending flags present since cucumber 1.x ([#1738](https://github.com/cucumber/cucumber-ruby/pull/1738) [luke-hill](https://github.com/luke-hill))

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

[Unreleased]: https://github.com/cucumber/cucumber-ruby/compare/v10.2.0...HEAD
[10.2.0]: https://github.com/cucumber/cucumber-ruby/compare/v10.1.1...v10.2.0
[10.1.1]: https://github.com/cucumber/cucumber-ruby/compare/v10.1.0...v10.1.1
[10.1.0]: https://github.com/cucumber/cucumber-ruby/compare/v10.0.0...v10.1.0
[10.0.0]: https://github.com/cucumber/cucumber-ruby/compare/v9.2.1...v10.0.0
[9.2.1]: https://github.com/cucumber/cucumber-ruby/compare/v9.2.0...v9.2.1
[9.2.0]: https://github.com/cucumber/cucumber-ruby/compare/v9.1.2...v9.2.0
[9.1.2]: https://github.com/cucumber/cucumber-ruby/compare/v9.1.1...v9.1.2
[9.1.1]: https://github.com/cucumber/cucumber-ruby/compare/v9.1.0...v9.1.1
[9.1.0]: https://github.com/cucumber/cucumber-ruby/compare/v9.0.2...v9.1.0
[9.0.2]: https://github.com/cucumber/cucumber-ruby/compare/v9.0.1...v9.0.2
[9.0.1]: https://github.com/cucumber/cucumber-ruby/compare/v9.0.0...v9.0.1
[9.0.0]: https://github.com/cucumber/cucumber-ruby/compare/v8.0.0...v9.0.0
[8.0.0]: https://github.com/cucumber/cucumber-ruby/compare/v8.0.0.RC.1...v8.0.0
[8.0.0.RC.1]: https://github.com/cucumber/cucumber-ruby/compare/v7.1.0...v8.0.0.RC.1
