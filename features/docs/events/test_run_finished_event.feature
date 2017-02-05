Feature: Test Run Finished

  This event is fired after all the test cases have been executed.

  Typically, a formatter would use this to print out summary information.

  At the moment this event contains no data, but it could be extended 
  in the future to carry the summary information for the convenience 
  of formatter authors.

  Background:
    Given the standard step definitions
    And a file named "features/test.feature" with:
      """
      Feature: A feature

        Scenario: A passing scenario
          Given this is a step
      """
    And a file named "features/support/events.rb" with:
      """
      class MyFormatter
        def initialize(config)
          config.on_event :test_case_finished do
            config.out_stream.puts "test case finished"
          end
          config.on_event :test_run_finished do
            config.out_stream.puts "the end"
          end
        end
      end
      """

  Scenario: Run the test case
    When I run `cucumber -q -f MyFormatter`
    Then it should pass with:
      """
      test case finished
      the end
      """
