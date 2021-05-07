Feature: Empty scenario

  A scenario can be empty.
  Background and hooks are not executed.
  The state of the resulting test for the scenario is `undefined`

  Background:
    Given a file named "features/empty_scenario.feature" with:
      """
      Feature: minimal

        Background:
          Given some context 

        Scenario: empty
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given("some context") do
        raise "error" # should not be executed
      end

      After do |scenario|
        raise "error" # should not be executed
      end
      """

  Scenario: test status for empty scenario is `undefined`
    When I run `cucumber --quiet features/empty_scenario.feature`
    Then it should pass with exactly:
    """
    Feature: minimal

      Background:

    1 scenario (1 undefined)
    0 steps
    """

  Scenario: reporting with the JSON formatter
    When I run `cucumber --quiet --format json features/empty_scenario.feature`
    Then it should pass with JSON:
    """
    [
      {
        "description": "",
        "elements": [
          {
            "id": "minimal;empty",
            "description": "",
            "keyword": "Scenario",
            "line": 6,
            "name": "empty",
            "steps": [],
            "type": "scenario"
          }
        ],
        "id": "minimal",
        "keyword": "Feature",
        "line": 1,
        "name": "minimal",
        "uri": "features/empty_scenario.feature"
      }
    ]
    """
