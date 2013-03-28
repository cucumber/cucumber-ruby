Feature: https://github.com/cucumber/cucumber/issues/175

  Scenario: Don't display docstrings when using --no-multiline
    Given a standard Cucumber project directory structure
    And a file named "features/f.feature" with:
      """
      Feature: Test
      In order to test
      As a tester
      I want to test

        Scenario: Testing
          Given a table:
           | foo  | bar  |
           | quux | ding |
          Given a multiline string:
          \"\"\"
          with many lines of code
          \"\"\"
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /a multiline string:/ do |s|
      end
      Given /a table:/ do |t|
      end
      """

    When I run cucumber --format pretty --no-multiline features/f.feature
    And the output should not contain
    """
    with many lines of code
    """
    And the output should not contain
    """
    | foo  | bar  |
    | quux | ding |
    """
