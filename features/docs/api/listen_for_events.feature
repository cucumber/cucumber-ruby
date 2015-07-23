Feature: Listen for events

  Scenario: Step Matched Event
    Given a file named "features/test.feature" with:
      """
      Feature:
        Scenario:
          Given matching
      """
    And a file named "features/steps_definitions/steps.rb" with:
      """
      Given(/matching/) do
      end
      """
    And a file named "features/support/my_listener.rb" with:
      """
      AfterConfiguration do |config|
        config.on_event :step_match do |event|
          puts "Success!"
          expect(event).to be_a(Cucumber::Events::StepMatch)
          expect(event.test_step.name).to eq "passing"
          expect(event.step_match.regexp_source.location.to_s).to eq "features/step_definitions/steps.rb:1"
        end
      end
      """
    When I run `cucumber`
    Then it should pass with:
      """
      Success!
      """
