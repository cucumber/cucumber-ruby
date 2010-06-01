Feature: JSON output formatter
  In order to get results as data
  As a developer
  Cucumber should be able to output JSON

  Scenario: one feature, one passing scenario, one failing scenario
    Given I am in json
    When I run cucumber --format json_pretty features/one_passing_one_failing.feature
    Then it should fail with
      """
      {
        "features": [
          {
            "file": "features/one_passing_one_failing.feature",
            "name": "One passing scenario, one failing scenario",
            "tags": [
              "@a"
            ],
            "elements": [
              {
                "tags": [
                  "@b"
                ],
                "name": "Passing",
                "steps": [
                  {
                    "status": "passed",
                    "name": "Given a passing scenario",
                    "file_colon_line": "features/step_definitions/steps.rb:1"
                  }
                ]
              },
              {
                "tags": [
                  "@c"
                ],
                "name": "Failing",
                "steps": [
                  {
                    "exception": {
                      "class": "RuntimeError",
                      "message": "",
                      "backtrace": [
                        "./features/step_definitions/steps.rb:6:in `/a failing scenario/'",
                        "features/one_passing_one_failing.feature:10:in `Given a failing scenario'"
                      ]
                    },
                    "status": "failed",
                    "name": "Given a failing scenario",
                    "file_colon_line": "features/step_definitions/steps.rb:5"
                  }
                ]
              }
            ]
          }
        ]
      }
      """
