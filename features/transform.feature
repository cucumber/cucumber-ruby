Feature: transform
  In order to maintain modularity within step definitions
  As a step definition editor
  I want to register a regex to capture and tranform step definition arguments.

  Background:         
    Given a standard Cucumber project directory structure
    And a file named "features/step_definitions/steps.rb" with:
      """
      Then /^I should transform ('\d+' to an Integer)$/ do |integer|
        integer.should be_kind_of(Integer)
      end

      Then /^I should transform ('\w+' to a Symbol)$/ do |symbol|
        symbol.should be_kind_of(Symbol)
      end

      Then /^I should transform ('\d+' to a Float)$/ do |float|
        float.should be_kind_of(Float)
      end

      Then /^I should transform ('\w+' to an Array)$/ do |array|
        array.should be_kind_of(Array)
      end

      Then /^I should not transform ('\d+') to an Integer$/ do |string|
        string.should be_kind_of(String)
      end
      """
    And a file named "features/support/env.rb" with:
      """
      Transform /^'\d+' to an Integer$/ do |step_arg|
        /'(\d+)' to an Integer/.match(step_arg).captures[0].to_i
      end

      Transform /^'(\d+)' to a Float$/ do |integer_string|
        Float.induced_from Transform("'#{integer_string}' to an Integer")
      end

      Transform(/^('\w+') to a Symbol$/) {|str| str.to_sym }

      module MyHelpers
        def fetch_array
          @array
        end
      end

      World(MyHelpers)

      Before do
        @array = []
      end

      Transform(/^('\w+') to an Array$/) {|str| fetch_array }
      """
      
  Scenario: run a specific scenario with a registered transform
    Given a file named "features/transform_sample.feature" with:
      """
      Feature: Step argument transformations

        Scenario: transform with matches
          Then I should transform '10' to an Integer

        Scenario: transform with matches that capture
          Then I should transform 'abc' to a Symbol

        Scenario: transform with matches that reuse transforms
          Then I should transform '10' to a Float

        Scenario: transform with matches that use current world
          Then I should transform 'abc' to an Array

        Scenario: transform without matches
          Then I should not transform '10' to an Integer
      """
    When I run cucumber -s features
    Then it should pass with
      """
      Feature: Step argument transformations
    
        Scenario: transform with matches
          Then I should transform '10' to an Integer

        Scenario: transform with matches that capture
          Then I should transform 'abc' to a Symbol

        Scenario: transform with matches that reuse transforms
          Then I should transform '10' to a Float

        Scenario: transform with matches that use current world
          Then I should transform 'abc' to an Array

        Scenario: transform without matches
          Then I should not transform '10' to an Integer

      5 scenarios (5 passed)
      5 steps (5 passed)
    
      """
