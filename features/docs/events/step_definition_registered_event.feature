Feature: Step definition registered

  This event is fired when Cucumber loads the user's step definitions. Typically, this is
  when the `Given /^my step$/ do` methods are called.

  See [the API documentation](http://www.rubydoc.info/github/cucumber/cucumber-ruby/Cucumber/Events/StepDefinitionRegistered) for more information about the data available on this event.

  Scenario: Register a new step definition
    Given the standard step definitions
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /a step/ do
        # automation goes here
      end
      """
    And a file named "features/support/events.rb" with:
      """
      AfterConfiguration do |config|
        config.on_event :step_definition_registered do |event|
          config.out_stream.puts "The step definition: #{event.step_definition.location}"
        end
      end
      """
    When I run `cucumber`
    Then it should pass with:
      """
      The step definition: features/step_definitions/steps.rb:1
      """

