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
            @io.puts "  #{test_case.name.upcase}"
          end
        end
      end
      """
    When I run `cucumber features/f.feature --format MyCustom::Formatter`
    Then it should pass with exactly:
      """
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
