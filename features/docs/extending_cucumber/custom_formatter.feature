Feature: Custom Formatter

  Scenario: my own formatter
    Given a file named "features/f.feature" with:
      """
      Feature: I'll use my own
        because I'm worth it
        Scenario: just print me
          Given this step passes
      """
    And the standard step definitions
    And a file named "features/support/ze/formator.rb" with:
      """
      module Ze
        class Formator
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
    When I run `cucumber features/f.feature --format Ze::Formator`
    Then it should pass with exactly:
      """
      I'LL USE MY OWN
        JUST PRINT ME

      """
