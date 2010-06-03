Feature: JSON output formatter
  In order to get results as data
  As a developer
  Cucumber should be able to output JSON

  Background:
    Given I am in json

  Scenario: one feature, one passing scenario, one failing scenario
    And the tmp directory is empty
    When I run cucumber --format json --out tmp/out.json features/one_passing_one_failing.feature
    Then it should fail with
      """
      """
    And "examples/json/tmp/out.json" should match "^\{\"features\":\["

  Scenario: one feature, one passing scenario, one failing scenario
    When I run cucumber --format json_pretty features/one_passing_one_failing.feature
    Then it should fail with JSON
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
                "keyword": "Scenario",
                "name": "Passing",
                "file_colon_line": "features/one_passing_one_failing.feature:5",
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
                "keyword": "Scenario",
                "name": "Failing",
                "file_colon_line": "features/one_passing_one_failing.feature:9",
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

  Scenario: Scenario Outline
    When I run cucumber --format json_pretty features/outline.feature
    Then it should fail with JSON
      """
      {
        "features": [
          {
            "file": "features/outline.feature",
            "name": "A scenario outline",
            "tags": [

            ],
            "elements": [
              {
                "tags": [

                ],
                "keyword": "Scenario Outline",
                "name": "",
                "file_colon_line": "features/outline.feature:3",
                "steps": [
                  {
                    "status": "skipped",
                    "name": "Given I add <a> and <b>",
                    "file_colon_line": "features/step_definitions/steps.rb:13"
                  },
                  {
                    "status": "skipped",
                    "name": "Then I the result should be <c>",
                    "file_colon_line": "features/step_definitions/steps.rb:17"
                  }
                ],
                "examples": {
                  "name": "Examples ",
                  "table": [
                    {
                      "values": [
                        {
                          "value": "a",
                          "status": "skipped_param"
                        },
                        {
                          "value": "b",
                          "status": "skipped_param"
                        },
                        {
                          "value": "c",
                          "status": "skipped_param"
                        }
                      ]
                    },
                    {
                      "values": [
                        {
                          "value": "1",
                          "status": "passed"
                        },
                        {
                          "value": "2",
                          "status": "passed"
                        },
                        {
                          "value": "3",
                          "status": "passed"
                        }
                      ]
                    },
                    {
                      "values": [
                        {
                          "value": "2",
                          "status": "passed"
                        },
                        {
                          "value": "3",
                          "status": "passed"
                        },
                        {
                          "value": "4",
                          "status": "failed"
                        }
                      ],
                      "exception": {
                        "class": "Spec::Expectations::ExpectationNotMetError",
                        "message": "expected: 4,\n     got: 5 (using ==)\n\n Diff:\n@@ -1,2 +1,2 @@\n-4\n+5\n",
                        "backtrace": [
                          "./features/step_definitions/steps.rb:18:in `/^I the result should be (\\d+)$/'",
                          "features/outline.feature:5:in `Then I the result should be <c>'"
                        ]
                      }
                    }
                  ]
                }
              }
            ]
          }
        ]
      }
      """
  Scenario: pystring
    When I run cucumber --format json_pretty features/pystring.feature
    Then it should pass with JSON
    """
      {
        "features": [
          {
            "file": "features/pystring.feature",
            "name": "A py string feature",
            "tags": [

            ],
            "elements": [
              {
                "tags": [

                ],
                "keyword": "Scenario",
                "name": "",
                "file_colon_line": "features/pystring.feature:3",
                "steps": [
                  {
                    "status": "passed",
                    "name": "Then I should see",
                    "file_colon_line": "features/step_definitions/steps.rb:21",
                    "py_string": "a string"
                  }
                ]
              }
            ]
          }
        ]
      }
    """
