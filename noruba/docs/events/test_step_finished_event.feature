Feature: Test Step Finished Event

  This event is fired after each step in a scenario or scenario outline example 
  (generally named a Test Step) has finished executing. You can use the event to learn about the 
  result of the test step.

  See [the API documentation](http://www.rubydoc.info/github/cucumber/cucumber-ruby/Cucumber/Events/TestStepFinished) for more information about the data available on this event and the result object.

  Background:
    Given the standard step definitions
    And a file named "features/test.feature" with:
      """
      Feature: A feature

        @pass
        Scenario: A passing scenario
          Given this step passes

        @fail
        Scenario: A failing scenario
          Given this step fails
      """
    And a file named "features/support/events.rb" with:
      """
      AfterConfiguration do |config|
        config.on_event :test_step_finished do |event|
          config.out_stream.puts "Test step: #{event.test_step}"
          config.out_stream.puts "The result is: #{event.result}"
        end
      end
      """

  Scenario: Test step passes
    When I run `cucumber --tags @pass`
    Then it should pass with:
      """
      Test step: this step passes
      The result is: ✓
      """

  Scenario: Test step fails
    When I run `cucumber --tags @fail`
    Then it should fail with:
      """
      Test step: this step fails
      The result is: ✗
      """
