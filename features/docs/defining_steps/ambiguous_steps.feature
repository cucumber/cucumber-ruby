Feature: Ambiguous Steps

  When Cucumber searches for a step definition for a step, it might find multiple step
  definitions that could match. In that case, it will give you an error that the step
  definitions are ambiguous.

  You can also use a `--guess` mode, where it uses magic powers to try and figure
  out which of those two step definitions is most likely to be the one you meant it
  to use. Use it with caution!


  Scenario: Ambiguous steps

    Given a file named "features/ambiguous.feature" with:
    """
    Feature:

      Scenario:
      When a step
      Then an ambiguous step

    """
    And a file named "features/step_definitions.rb" with:
    """
      When(/^a.*step$/) do
        'foo'
      end

      Then(/^an ambiguous step$/) do
        'bar'
      end

    """
    When I run `cucumber`
    Then it should fail with:
    """
          Ambiguous match of "an ambiguous step":
          
          features/step_definitions.rb:1:in `/^a.*step$/'
          features/step_definitions.rb:5:in `/^an ambiguous step$/'
          
          You can run again with --guess to make Cucumber be more smart about it
           (Cucumber::Ambiguous)
          features/ambiguous.feature:5:in `Then an ambiguous step'

    Failing Scenarios:
    cucumber features/ambiguous.feature:3 # Scenario: 

    1 scenario (1 failed)
    2 steps (1 failed, 1 passed)
    0m0.012s

    """


  Scenario: Ambiguous steps with guess mode

    Given a file named "features/ambiguous.feature" with:
    """
    Feature:

      Scenario:
      When a step
      Then an ambiguous step
    """
    And a file named "features/step_definitions.rb" with:
    """
      When(/^a.*step$/) do
        'foo'
      end

      Then(/^an ambiguous step$/) do
        'bar'
      end
    """
    When I run `cucumber -g`
    Then it should pass with exactly:
    """
    Feature: 

      Scenario:                # features/ambiguous.feature:3
        When a step            # features/step_definitions.rb:1
        Then an ambiguous step # features/step_definitions.rb:5

    1 scenario (1 passed)
    2 steps (2 passed)
    0m0.012s

    """