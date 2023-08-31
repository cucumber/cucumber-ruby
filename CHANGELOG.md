# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org).

This document is formatted according to the principles of [Keep A CHANGELOG](http://keepachangelog.com).

Please visit [cucumber/CONTRIBUTING.md](https://github.com/cucumber/cucumber/blob/master/CONTRIBUTING.md) for more info on how to contribute to Cucumber.

## [Unreleased]
### Added
* Add option `--retry-total` ([#1669](https://github.com/cucumber/cucumber-ruby/pull/1669))

### Changed
* Update dependency cucumber-gherkin to v26 ([#1688](https://github.com/cucumber/cucumber-ruby/pull/1688))
* Replace dependency [mime-types](https://rubygems.org/gems/mime-types)
  with [mini_mime](https://rubygems.org/gems/mini_mime)
  ([#1695](https://github.com/cucumber/cucumber-ruby/pull/1695))

### Deprecated

### Fixed
- Cucumber may raise NoMethodError when CUCUMBER_COLORS environment was set ([PR#1641](https://github.com/cucumber/cucumber-ruby/pull/1641/) [s2k](https://github.com/s2k))

### Removed
- Removed support for Ruby 2.6 and JRuby 9.3 ([PR#1699](https://github.com/cucumber/cucumber-ruby/pull/1699))
