Feature: Listen for events

  @spawn
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
        config.on_event Cucumber::Events::StepMatch do |event|
          puts "Success!"
          puts "Event type:      #{event.class}"
          puts "Step name:       #{event.test_step.name}"
          puts "Source location: #{event.step_match.location}"
        end
      end
      """
    When I run `cucumber`
    Then it should pass with:
      """
      Success!
      Event type:      Cucumber::Events::StepMatch
      Step name:       matching
      Source location: features/step_definitions/steps.rb:1
      """
