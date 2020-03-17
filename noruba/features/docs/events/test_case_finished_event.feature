Feature: Test Case Finished Event

  This event is fired after each scenario or examples table row (generally named a 
  Test Case) has finished executing. You can use the event to learn about the 
  result of the test case.

  See [the API documentation](http://www.rubydoc.info/github/cucumber/cucumber-ruby/Cucumber/Events/TestCaseFinished) for more information about the data available on this event.

  Scenario: Test case passes
    Given the standard step definitions
    And a file named "features/passing.feature" with:
      """
      Feature: A feature
        Scenario: A scenario
          Given this step passes
      """
    And a file named "features/support/events.rb" with:
      """
      AfterConfiguration do |config|
        config.on_event :test_case_finished do |event|
          config.out_stream.puts "Results"
          config.out_stream.puts "-------"
          config.out_stream.puts "Test case: #{event.test_case.name}"
          config.out_stream.puts "The result is: #{event.result}"
        end
      end
      """
    When I run `cucumber`
    Then it should pass with:
      """
      Results
      -------
      Test case: A scenario
      The result is: ✓
      """
