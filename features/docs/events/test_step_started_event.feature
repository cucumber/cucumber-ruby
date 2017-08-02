Feature: Test Step Started Event

  This event is fired just before each step in a scenario or scenario outline example 
  (generally named a Test Step) starts to be executed. This event is read-only, so there
  is no way to prevent the test step from running, but you can use it for logging or user
  notification.

  See [the API documentation](http://www.rubydoc.info/github/cucumber/cucumber-ruby/Cucumber/Events/TestStepStarted) for more information about the data available on this event and the result object.

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
      stdout = nil
      AfterConfiguration do |config|
        stdout = config.out_stream # make sure all the `puts` calls can write to the same output
        config.on_event :test_step_started do |event|
          stdout.puts "before"
        end
        config.on_event :test_step_finished do |event|
          stdout.puts "after"
        end
      end
      Given(/this is a step/) do
        stdout.puts "during"
      end
      """

  Scenario: Test step passes
    When I run `cucumber`
    Then it should pass with:
      """
      before
      during
      after
      """
