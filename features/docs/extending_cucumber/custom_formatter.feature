Feature: Custom Formatter

  Background:
    Given a file named "features/f.feature" with:
      """
      Feature: I'll use my own
        Scenario: Just print me
          Given this step passes
      """
    And the standard step definitions

  Scenario: Use the new API
    While we transition to a new API, it's neccesary to explicity opt-in by responding to
    the 'formatter_api_shim' method.

    Legacy methods will be ignored.

    Given a file named "features/support/custom_formatter.rb" with:
      """
      module MyCustom
        class Formatter
          def self.formatter_api_shim
            Cucumber::Formatter::Shim::None
          end

          def initialize(runtime, io, options)
            @io = io
          end

          def before_test_case(test_case)
            @io.puts test_case.feature.short_name.upcase
            @io.puts "  #{test_case.source.scenario.name.upcase}"
          end

          def before_feature(feature)
            @io.puts "THIS SHOULD NOT APPEAR"
          end
        end
      end
      """
    When I run `cucumber features/f.feature --format MyCustom::Formatter`
    Then it should pass with exactly:
      """
      I'LL USE MY OWN
        JUST PRINT ME

      """

  Scenario: Use the legacy API
    The legacy API is the default, for now.

    Given a file named "features/support/custom_legacy_formatter.rb" with:
      """
      module MyCustom
        class LegacyFormatter
          def initialize(runtime, io, options)
            @io = io
          end

          def before_feature(feature)
            @io.puts feature.short_name.upcase
          end

          def scenario_name(keyword, name, file_colon_line, source_indent)
            @io.puts "  #{name.upcase}"
          end

          def before_test_case(test_case)
            @io.puts "THIS SHOULD NOT APPEAR"
          end
        end
      end
      """
    When I run `cucumber features/f.feature --format MyCustom::LegacyFormatter`
    Then it should pass with exactly:
      """
      I'LL USE MY OWN
        JUST PRINT ME

      """

  Scenario: Use both
    You can use a specific shim to opt-in to both APIs at once.

    Given a file named "features/support/custom_mixed_formatter.rb" with:
      """
      module MyCustom
        class MixedFormatter
          def self.formatter_api_shim
            Cucumber::Formatter::Shim::Mixed
          end

          def initialize(runtime, io, options)
            @io = io
          end

          def before_test_case(test_case)
            @io.puts test_case.feature.short_name.upcase
          end

          def scenario_name(keyword, name, file_colon_line, source_indent)
            @io.puts "  #{name.upcase}"
          end
        end
      end
      """
    When I run `cucumber features/f.feature --format MyCustom::MixedFormatter`
    Then it should pass with exactly:
      """
      I'LL USE MY OWN
        JUST PRINT ME

      """
