Feature: Step Activated Event

  This event is fired when Cucumber finds a matching definition for a Gherkin step.

  See [the API documentation](http://www.rubydoc.info/github/cucumber/cucumber-ruby/Cucumber/Events/StepActivated)
  for more information about the data available on this event.

  Scenario: Activate a step
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Given /a step/ do
        # automation goes here
      end
      """
    And a file named "features/test.feature" with:
      """
      Feature:
        Scenario:
          Given a step
      """
    And a file named "features/support/events.rb" with:
      """
      AfterConfiguration do |config|
        config.on_event :step_activated do |event|
          config.out_stream.puts "The step: #{event.test_step.location}"
          config.out_stream.puts "The step definition: #{event.step_match.location}"
        end
      end
      """
    When I run `cucumber`
    Then it should pass with:
      """
      The step: features/test.feature:3
      The step definition: features/step_definitions/steps.rb:1
      """

