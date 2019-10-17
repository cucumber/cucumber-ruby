Feature: Rule

  When running an example mapping session, you end up with four kind of cards: features, rules, examples and questions.
  Since Gherkin 6, this is easily translated in your feature files.

  Background:
    Given a file named "features/rule.feature" with:
      """
      Feature: Rule Sample

        Rule: This is a rule

          Example: First example
            Given some context
            When I do an action
            Then some results should be there

          Example: Second example
            Given some context
            When I do another action
            Then some other results should be there

        Rule: This is a second rule

          Example: First example
            Given some context
            When I do another action
            Then some results should be there
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given("some context") { }
      When("I do an action") { }
      Then("some results should be there") { }
      When("I do another action") { }
      Then("some other results should be there") { }

      """


  Rule: I use Gherkin 6+
    Example: I can use the Rule keyword
      When I run `cucumber -q features/rule.feature`
      Then it should pass with exactly:
      """
      Feature: Rule Sample

        Example: First example
          Given some context
          When I do an action
          Then some results should be there

        Example: Second example
          Given some context
          When I do another action
          Then some other results should be there

        Example: First example
          Given some context
          When I do another action
          Then some results should be there

      3 scenarios (3 passed)
      9 steps (9 passed)
      """
