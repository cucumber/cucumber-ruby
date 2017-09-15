Feature: Custom Formatter

  Background:
    Given a file named "features/f.feature" with:
      """
      Feature: I'll use my own
        Scenario: Just print me
          Given this step passes
      """
    And the standard step definitions

  Scenario: Subscribe to result events

    This is the recommended way to format output.

    Given a file named "features/support/custom_formatter.rb" with:
      """
      module MyCustom
        class Formatter
          def initialize(config)
            @io = config.out_stream
            config.on_event :test_case_started do |event|
              print_test_case_name(event.test_case)
            end
          end

          def print_test_case_name(test_case)
            feature = test_case.source.first
            scenario = test_case.source.last
            @io.puts feature.short_name.upcase
            @io.puts "  #{scenario.name.upcase}"
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

  Scenario: Pass custom config to your formatter from the CLI
    Given a file named "features/support/custom_formatter.rb" with:
      """
      module MyCustom
        class Formatter
          def initialize(config, options)
            @io = config.out_stream
            config.on_event :test_run_finished do |event|
              @io.print options.inspect
            end
          end
        end
      end
      """
    When I run `cucumber features/f.feature --format MyCustom::Formatter,foo=bar,one=two`
    Then it should pass with exactly:
    """
    {"foo"=>"bar", "one"=>"two"}
    """

  Scenario: Use the legacy API
    This is deprecated and should no longer be used.

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
        end
      end
      """
    When I run `cucumber features/f.feature --format MyCustom::LegacyFormatter`
    Then it should pass with exactly:
      """
      WARNING: The formatter MyCustom::LegacyFormatter is using the deprecated formatter API which will be removed in v4.0 of Cucumber.

      I'LL USE MY OWN
        JUST PRINT ME

      """

