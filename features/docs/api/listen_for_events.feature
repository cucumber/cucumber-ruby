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
        config.on_event :step_activated do |event|
          io.puts "Success!"
          io.puts "Step text:       #{event.test_step}"
          io.puts "Source location: #{event.step_match.location}"
        end
      end
      """
    When I run `cucumber`
    Then it should pass with:
      """
      Success!
      Step text:       matching
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
        config.on_event :test_step_finished do |event|
          io.puts event.result.passed?
        end
      end
      """
    When I run `cucumber`
    Then it should pass with:
      """
      true
      """

