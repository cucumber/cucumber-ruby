Feature: Test Case Finished Event

  This event is fired after each scenario or examples table row (generally named a 
  Test Case) has finished executing. You can use the event to learn about the 
  result of the test case.

  Scenario: Test case passes
    Given the standard step definitions
    And a file named "features/passing.feature" with:
      """
      Feature:
        Scenario:
          Given this step passes
      """
    And a file named "features/support/events.rb" with:
      """
      AfterConfiguration do |config|
        config.on_event :test_case_finished do |event|
          config.out_stream.puts "The result is #{event.result}"
        end
      end
      """
    When I run `cucumber`
    Then it should pass with:
      """
      The result is ✓
      """
