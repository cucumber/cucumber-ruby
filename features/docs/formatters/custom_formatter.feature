Feature: Custom formatter
  Add test coverage for utility functions which are not used by other flows.

  Scenario: test Cucumber::Formatter::Io::ensure_file
    Given a file named "features/f.feature" with:
      """
      Feature: Test
        Scenario: Test
      """
    And a file named "features/support/custom_formatter.rb" with:
      """
      require 'cucumber/formatter/io'
      module Cucumber
        module Formatter
          class Test
            include Io
            def initialize(runtime, path_or_io, options)
              ensure_file("features/f.feature", "features file")
            end
          end
        end
      end
      """
    When I run `cucumber features/f.feature --format Cucumber::Formatter::Test`
    Then it should pass
