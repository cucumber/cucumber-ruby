Feature: https://github.com/cucumber/cucumber/issues/175

  @dev
  Scenario: the html shouldn't include 'Using the default profile...'
    Given a standard Cucumber project directory structure
    And the following profile is defined:
    """
      default: --strict
      """
    When I run cucumber --profile default --format html
    Then it should pass
    And the output should not contain
    """
    Using the default profile...
    """
