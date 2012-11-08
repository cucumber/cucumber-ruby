Feature: Step Definitions

  Everybody knows you can do step definitions in Cucumber
  but did you know you can do this?

  Scenario: Call a method in World directly from a step def
    Given a file named "features/step_definitions/steps.rb" with:
      """
      module Driver
        def do_action
          @done = true
        end

        def assert_done
          @done.should be_true
        end
      end
      World(Driver)

      When /I do the action/, :do_action
      Then /The action should be done/, :assert_done
      """
    And a file named "features/action.feature" with:
      """
      Feature:
        Scenario:
          When I do the action
          Then the action should be done
      """

