Feature: Test Step is available in AfterStep Block
  In order to inspect a Test Step after it has executed
  As a developer
  I want Test Step objects available in AfterStep blocks

  Background:
    Given the standard step definitions
    And a file named "features/sample.feature" with:
      """
      Feature: Sample

        Scenario: Success
          Given this step passes
      """

  Scenario: Access Test Step object in AfterStep Block
    Given a file named "features/support/env.rb" with:
      """
      AfterStep do |result, test_step|
        expect(test_step).to be_a(Cucumber::Core::Test::Step)
      end
      """
    When I run `cucumber features`
    Then it should pass with:
      """
      Feature: Sample

        Scenario: Success        # features/sample.feature:3
          Given this step passes # features/step_definitions/steps.rb:1

      1 scenario (1 passed)
      1 step (1 passed)

      """

  Scenario: An AfterStep with one named argument does not change behavior
    Given a file named "features/support/env.rb" with:
      """
      AfterStep do |result|
        expect(result).to be_a(Cucumber::Core::Test::Result::Passed)
      end
      """
    When I run `cucumber features`
    Then it should pass with:
      """
      Feature: Sample

        Scenario: Success        # features/sample.feature:3
          Given this step passes # features/step_definitions/steps.rb:1

      1 scenario (1 passed)
      1 step (1 passed)

      """