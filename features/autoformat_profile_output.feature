Feature: Autoformat profile output

  Background:
    Given a file named "features/autoformat_output_has_profile_info.feature" with:
      """
      Feature:

        Scenario: Passing
          Given passing
      """

  Scenario: when using a profile the output should include 'Using the default profile...'
    And a file named "cucumber.yml" with:
    """
      default: -r features
    """
    When I run `cucumber --profile default --autoformat tmp`
    Then it should pass
    And the output should contain:
    """
    Using the default profile...
    """

