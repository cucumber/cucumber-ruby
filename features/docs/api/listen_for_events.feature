Feature: Listen for events

  Cucumber's `config` object has an event bus that you can use to listen for
  various events that happen during your test run.

  Scenario: Step Matched Event
    Given a file named "features/test.feature" with:
      """
      Feature:
        Scenario:
          Given matching
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given(/matching/) do
      end
      """
    And a file named "features/support/my_listener.rb" with:
      """
      AfterConfiguration do |config|
        io = config.out_stream
        config.on_event Cucumber::Events::StepMatch do |test_step, step_match|
          io.puts "Success!"
          io.puts "Step name:       #{test_step.name}"
          io.puts "Source location: #{step_match.location}"
        end
      end
      """
    When I run `cucumber`
    Then it should pass with:
      """
      Success!
      Step name:       matching
      Source location: features/step_definitions/steps.rb:1
      """

  Scenario: After Test Step event
    Given a file named "features/test.feature" with:
      """
      Feature:
        Scenario:
          Given passing
      """
    And the standard step definitions
    And a file named "features/support/my_listener.rb" with:
      """
      AfterConfiguration do |config|
        io = config.out_stream
        config.on_event Cucumber::Core::Events::TestStepFinished do |test_step, result|
          io.puts "YO"
        end
      end
      """
    When I run `cucumber`
    Then it should pass with:
      """
      YO
      """

