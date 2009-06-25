Feature: --formatter steps option - Steps Formatter
  In order to easily see which steps are already defined,
  specially when using 3rd party steps libraries,
  Cucumber should show the available steps in a user-friendly format

  Background:
    Given I am in steps_library

  Scenario: Printing steps
    When I run cucumber -f steps features
    Then it should pass with
    """
    features/step_definitions/steps_lib1.rb
      /^I defined a first step$/           # features/step_definitions/steps_lib1.rb:1
      /^I define a second step$/           # features/step_definitions/steps_lib1.rb:4
      /^I should also have a third step$/  # features/step_definitions/steps_lib1.rb:7
    
    features/step_definitions/steps_lib2.rb
      /^I defined a step 4$/                # features/step_definitions/steps_lib2.rb:1
      /^I create a step 5$/                 # features/step_definitions/steps_lib2.rb:4
      /^I should be too tired for step 6$/  # features/step_definitions/steps_lib2.rb:7
    
    6 step definition(s) in 2 source file(s).

    """