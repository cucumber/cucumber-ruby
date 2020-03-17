Feature: Example

  Example is a synonym for Scenario.

  Background:
    Given a file named "features/example.feature" with:
      """
      Feature: A simple example

        Example: First example
          Given some context
          When I do an action
          Then some results should be there
      """
    And a file named "features/second_example.feature" with:
      """
      Feature: Another example

        Example: First example
          Given some context
          When I do an action
          Then some results should be there
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given("some context") { }
      When("I do an action") { }
      Then("some results should be there") { }
      """

  Example: I can use the Example keyword
    When I run `cucumber -q features/example.feature`
    Then it should pass with exactly:
    """
    Feature: A simple example

      Example: First example
        Given some context
        When I do an action
        Then some results should be there

    1 scenario (1 passed)
    3 steps (3 passed)
    """

  Example: an Example can have multiple Examples
    When I run `cucumber -q <feature_file>`
    Then the output should contain:
    """
    <expected>
    """

    Examples:
      | feature_file                    | expected                  |
      | features/example.feature        | Feature: A simple example |
      | features/second_example.feature | Feature: Another example  |
