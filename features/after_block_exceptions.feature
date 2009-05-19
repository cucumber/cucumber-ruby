Feature: After Block Exceptions
  In order to use custom assertions at the end of each scenario
  As a developer
  I want exceptions raised in After blocks to be handled gracefully and reported by the formatters
  
  Scenario: Handle Exception in step and carry on
    Given a standard Cucumber project directory structure
    And a file named "features/two_scenarios.feature" with:
      """
      Feature: Sample

        Scenario: Naughty Step
          Given this step does something naughty

        Scenario: Success
          Given this step works
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /^this step does something naughty$/ do
        @naughty = true
      end

      Given /^this step works$/ do        
      end
      """
    And a file named "features/support/env.rb" with:
      """
      class NaughtyScenarioException < Exception; end
      After do
        if @naughty
          raise NaughtyScenarioException.new("This scenario has been very very naughty")
        end
      end
      """
    When I run cucumber features
    Then it should fail with 
      """
      Feature: Sample
      
        Scenario: Naughty Step                   # features/two_scenarios.feature:3
          Given this step does something naughty # features/step_definitions/steps.rb:1
            This scenario has been very very naughty (NaughtyScenarioException)
            ./features/support/env.rb:4:in `After'

        Scenario: Success       # features/two_scenarios.feature:6
          Given this step works # features/step_definitions/steps.rb:5
    
      2 scenarios (1 failed, 1 passed)
      2 steps (2 passed)
      
      """
  
