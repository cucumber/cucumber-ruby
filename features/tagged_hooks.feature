Feature: Tagged hooks

  Background:
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Given /^this step works$/ do; end
      """
    And a file named "features/support/hooks.rb" with:
      """
      Before('~@no-boom') do 
        raise 'boom'
      end
      """
    And a file named "features/f.feature" with:
      """
      Feature: With and without hooks
        Scenario: using hook
          Given this step works

        @no-boom
        Scenario: omitting hook
          Given this step works

        Scenario Outline: omitting hook on specified examples
          Given this step works

          Examples:
          | Value       |
          | Irrelevant  |

          @no-boom
          Examples:
          | Value           |
          | Also Irrelevant |
      """

  Scenario: omit tagged hook
    When I run `cucumber features/f.feature:2`
    Then it should fail with:
      """
      Feature: With and without hooks
      
        Scenario: using hook    # features/f.feature:2
        boom (RuntimeError)
        ./features/support/hooks.rb:2:in `Before'
          Given this step works # features/step_definitions/steps.rb:1
      
      Failing Scenarios:
      cucumber features/f.feature:2 # Scenario: using hook
      
      1 scenario (1 failed)
      1 step (1 skipped)

      """

    Scenario: omit tagged hook
      When I run `cucumber features/f.feature:6`
      Then it should pass with:
        """
        Feature: With and without hooks

          @no-boom
          Scenario: omitting hook # features/f.feature:6
            Given this step works # features/step_definitions/steps.rb:1

        1 scenario (1 passed)
        1 step (1 passed)

        """
    Scenario: omit example hook
      When I run `cucumber features/f.feature:12`
      Then it should fail with:
        """
        Feature: With and without hooks

          Scenario Outline: omitting hook on specified examples # features/f.feature:9
            Given this step works                               # features/step_definitions/steps.rb:1

            Examples: 
              | Value      |
              | Irrelevant |      boom (RuntimeError)
              ./features/support/hooks.rb:2:in `Before'

              boom (RuntimeError)
              ./features/support/hooks.rb:2:in `Before'

        Failing Scenarios:
        cucumber features/f.feature:9 # Scenario: omitting hook on specified examples

        1 scenario (1 failed)
        1 step (1 passed)

      """
    Scenario: 
      When I run `cucumber features/f.feature:17`
      Then it should pass



