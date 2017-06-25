Feature: Ambiguous Steps
 
  Scenario: Ambiguous steps

    Given a file named "features/ambiguous.feature" with:
    """
    Feature:

      Scenario: test 1
      * a step
      * an ambiguous step

      Scenario: test 2
      * step 1
      * step 2

    """
    And a file named "features/step_definitions.rb" with:
    """
      When(/^a.*step$/) do
        'foo'
      end

      When(/^an ambiguous step$/) do
        'bar'
      end

      When(/^step 1$/) do
        'baz'
      end

      When(/^step 2$/) do
        'buzz'
      end
    """
    When I run `cucumber`
    Then it should fail with exactly:
    """
    Feature:

      Scenario: test 1      # features/ambiguous.feature:3
        * a step            # features/step_definitions.rb:1
        * an ambiguous step # features/step_definitions.rb:5
           Error matching steps.
           Step text "an ambiguous step" would be match by
           - /^a.*step$/ at ./features/step_definitions.rb:1
           - /^an ambiguous step$/ at ./features/step_definitions.rb:6
           (Cucumber::Ambiguous)
          -e:1:in `load'
          -e:1:in `<main>'
          features/ambiguous.feature:5:in `* an ambiguous step'

      Scenario: test 2 # features/ambiguous.feature:7
        * step 1       # features/step_definitions.rb:9
        * step 2       # features/step_definitions.rb:13

    Failing Scenarios:
    cucumber features/ambiguous.feature:3 # Scenario: test 1

    2 scenarios (1 failed, 1 passed)
    4 steps (1 failed, 3 passed)
    0m0.012s
    """
