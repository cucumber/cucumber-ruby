Feature: JSON output formatter
  In order to simplify processing of Cucumber features and results
  Developers should be able to consume features as JSON

  Background:
    Given the standard step definitions
    And a file named "features/one_passing_one_failing.feature" with:
      """
      @a
      Feature: One passing scenario, one failing scenario

        @b
        Scenario: Passing
          Given this step passes

        @c
        Scenario: Failing
          Given this step fails
      """
    And a file named "features/step_definitions/json_steps.rb" with:
      """
      Given /^I attach a screenshot/ do
        File.open("screenshot.png", "w") { |file| file << "foo" }
        attach "screenshot.png", "image/png"
      end

      Given /^I print from step definition/ do
        log "from step definition"
      end

      Given /^I attach data directly/ do
        data = "YWJj"
        attach data, "mime-type;base64"
      end
      """
    And a file named "features/attachments.feature" with:
      """
      Feature: A screenshot feature

        Scenario:
          Given I attach a screenshot

      """
    And a file named "features/outline.feature" with:
      """
      Feature: An outline feature

        Scenario Outline: outline
          Given this step <status>

          Examples: examples1
            | status |
            | passes |
            | fails  |

          Examples: examples2
            | status |
            | passes |
      """
    And a file named "features/print_from_step_definition.feature" with:
      """
      Feature: A print from step definition feature

        Scenario:
          Given I print from step definition
          And I print from step definition

      """
    And a file named "features/print_from_step_definition.feature" with:
      """
      Feature: A print from step definition feature

        Scenario:
          Given I print from step definition
          And I print from step definition

      """
    And a file named "features/attach_data_directly.feature" with:
      """
      Feature: An embed data directly feature

        Scenario:
          Given I attach data directly

        Scenario Outline:
          Given I attach data directly

	  Examples:
	  | dummy |
	  |  1    |
	  |  2    |

      """
    And a file named "features/out_scenario_out_scenario_outline.feature" with:
      """
      Feature:
        Scenario:
          Given this step passes
        Scenario Outline:
          Given this step <status>
          Examples:
          | status |
          | passes |
      """

  # Need to investigate why this won't pass in-process. error_message doesn't get det?
  Scenario: one feature, one passing scenario, one failing scenario
    When I run `cucumber --format json features/one_passing_one_failing.feature`
    Then it should fail with JSON:
      """
      [
        {
          "uri": "features/one_passing_one_failing.feature",
          "keyword": "Feature",
          "id": "one-passing-scenario,-one-failing-scenario",
          "name": "One passing scenario, one failing scenario",
          "line": 2,
          "description": "",
          "tags": [
            {
              "name": "@a",
              "line": 1
            }
          ],
          "elements": [
            {
              "keyword": "Scenario",
              "id": "one-passing-scenario,-one-failing-scenario;passing",
              "name": "Passing",
              "line": 5,
              "description": "",
              "tags": [
                {
                  "name": "@a",
                  "line": 1
                },
                {
                  "name": "@b",
                  "line": 4
                }
              ],
              "type": "scenario",
              "steps": [
                {
                  "keyword": "Given ",
                  "name": "this step passes",
                  "line": 6,
                  "match": {
                    "location": "features/step_definitions/steps.rb:1"
                  },
                  "result": {
                    "status": "passed",
                    "duration": 1
                  }
                }
              ]
            },
            {
              "keyword": "Scenario",
              "id": "one-passing-scenario,-one-failing-scenario;failing",
              "name": "Failing",
              "line": 9,
              "description": "",
              "tags": [
                {
                  "name": "@a",
                  "line": 1
                },
                {
                  "name": "@c",
                  "line": 8
                }
              ],
              "type": "scenario",
              "steps": [
                {
                  "keyword": "Given ",
                  "name": "this step fails",
                  "line": 10,
                  "match": {
                    "location": "features/step_definitions/steps.rb:4"
                  },
                  "result": {
                    "status": "failed",
                    "error_message": " (RuntimeError)\n./features/step_definitions/steps.rb:4:in `/^this step fails$/'\nfeatures/one_passing_one_failing.feature:10:in `this step fails'",
                    "duration": 1
                  }
                }
              ]
            }
          ]
        }
      ]

      """

  Scenario: DocString
    Given a file named "features/doc_string.feature" with:
      """
      Feature: A DocString feature

        Scenario:
          Then I should fail with
            \"\"\"
            a string
            \"\"\"
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Then /I should fail with/ do |s|
        raise RuntimeError, s
      end
      """
    When I run `cucumber --format json features/doc_string.feature`
    Then it should fail with JSON:
      """
      [
        {
          "id": "a-docstring-feature",
          "uri": "features/doc_string.feature",
          "keyword": "Feature",
          "name": "A DocString feature",
          "line": 1,
          "description": "",
          "elements": [
            {
              "id": "a-docstring-feature;",
              "keyword": "Scenario",
              "name": "",
              "line": 3,
              "description": "",
              "type": "scenario",
              "steps": [
                {
                  "keyword": "Then ",
                  "name": "I should fail with",
                  "line": 4,
                  "doc_string": {
                    "content_type": "",
                    "value": "a string",
                    "line": 5
                  },
                  "match": {
                    "location": "features/step_definitions/steps.rb:1"
                  },
                  "result": {
                    "status": "failed",
                    "error_message": "a string (RuntimeError)\n./features/step_definitions/steps.rb:2:in `/I should fail with/'\nfeatures/doc_string.feature:4:in `I should fail with'",
                    "duration": 1
                  }
                }
              ]
            }
          ]
        }
      ]
      """

  Scenario: Attaching screenshot
    When I run `cucumber --format json features/attachments.feature`
    Then it should pass with JSON:
    """
    [
      {
        "uri": "features/attachments.feature",
        "id": "a-screenshot-feature",
        "keyword": "Feature",
        "name": "A screenshot feature",
        "line": 1,
        "description": "",
        "elements": [
          {
            "id": "a-screenshot-feature;",
            "keyword": "Scenario",
            "name": "",
            "line": 3,
            "description": "",
            "type": "scenario",
            "steps": [
              {
                "keyword": "Given ",
                "name": "I attach a screenshot",
                "line": 4,
                "embeddings": [
                  {
                    "mime_type": "image/png",
                    "data": "Zm9v"
                  }
                ],
                "match": {
                  "location": "features/step_definitions/json_steps.rb:1"
                },
                "result": {
                  "status": "passed",
                  "duration": 1
                }
              }
            ]
          }
        ]
      }
    ]

    """

  Scenario: scenario outline
    When I run `cucumber --format json features/outline.feature`
    Then it should fail with JSON:
    """
    [
      {
        "uri": "features/outline.feature",
        "id": "an-outline-feature",
        "keyword": "Feature",
        "name": "An outline feature",
        "line": 1,
        "description": "",
        "elements": [
          {
            "id": "an-outline-feature;outline;examples1;2",
            "keyword": "Scenario Outline",
            "name": "outline",
            "description": "",
            "line": 8,
            "type": "scenario",
            "steps": [
              {
                "keyword": "Given ",
                "name": "this step passes",
                "line": 4,
                "match": {
                  "location": "features/step_definitions/steps.rb:1"
                },
                "result": {
                  "status": "passed",
                  "duration": 1
                }
              }
            ]
          },
          {
            "id": "an-outline-feature;outline;examples1;3",
            "keyword": "Scenario Outline",
            "name": "outline",
            "description": "",
            "line": 9,
            "type": "scenario",
            "steps": [
              {
                "keyword": "Given ",
                "name": "this step fails",
                "line": 4,
                "match": {
                  "location": "features/step_definitions/steps.rb:4"
                },
                "result": {
                  "status": "failed",
                  "error_message": " (RuntimeError)\n./features/step_definitions/steps.rb:4:in `/^this step fails$/'\nfeatures/outline.feature:9:4:in `this step fails'",
                  "duration": 1
                }
              }
            ]
          },
          {
            "id": "an-outline-feature;outline;examples2;2",
            "keyword": "Scenario Outline",
            "name": "outline",
            "description": "",
            "line": 13,
            "type": "scenario",
            "steps": [
              {
                "keyword": "Given ",
                "name": "this step passes",
                "line": 4,
                "match": {
                  "location": "features/step_definitions/steps.rb:1"
                },
                "result": {
                  "status": "passed",
                  "duration": 1
                }
              }
            ]
          }
        ]
      }
    ]

    """

  Scenario: print from step definition
    When I run `cucumber --format json features/print_from_step_definition.feature`
    Then it should pass with JSON:
    """
    [
      {
        "uri": "features/print_from_step_definition.feature",
        "id": "a-print-from-step-definition-feature",
        "keyword": "Feature",
        "name": "A print from step definition feature",
        "line": 1,
        "description": "",
        "elements": [
          {
            "id": "a-print-from-step-definition-feature;",
            "keyword": "Scenario",
            "name": "",
            "line": 3,
            "description": "",
            "type": "scenario",
            "steps": [
              {
                "keyword": "Given ",
                "name": "I print from step definition",
                "line": 4,
                "output": [
                  "from step definition"
                ],
                "match": {
                  "location": "features/step_definitions/json_steps.rb:6"
                },
                "result": {
                  "status": "passed",
                  "duration": 1
                }
              },
              {
                "keyword": "And ",
                "name": "I print from step definition",
                "line": 5,
                "output": [
                  "from step definition"
                ],
                "match": {
                  "location": "features/step_definitions/json_steps.rb:6"
                },
                "result": {
                  "status": "passed",
                  "duration": 1
                }
              }
            ]
          }
        ]
      }
    ]

    """

  Scenario: scenario outline expanded
    When I run `cucumber --expand --format json features/outline.feature`
    Then it should fail with JSON:
    """
    [
      {
        "uri": "features/outline.feature",
        "id": "an-outline-feature",
        "keyword": "Feature",
        "name": "An outline feature",
        "line": 1,
        "description": "",
        "elements": [
          {
            "id": "an-outline-feature;outline;examples1;2",
            "keyword": "Scenario Outline",
            "name": "outline",
            "line": 8,
            "description": "",
            "type": "scenario",
            "steps": [
              {
                "keyword": "Given ",
                "name": "this step passes",
                "line": 4,
                "match": {
                  "location": "features/step_definitions/steps.rb:1"
                },
                "result": {
                  "status": "passed",
                  "duration": 1
                }
              }
            ]
          },
          {
            "id": "an-outline-feature;outline;examples1;3",
            "keyword": "Scenario Outline",
            "name": "outline",
            "line": 9,
            "description": "",
            "type": "scenario",
            "steps": [
              {
                "keyword": "Given ",
                "name": "this step fails",
                "line": 4,
                "match": {
                  "location": "features/step_definitions/steps.rb:4"
                },
                "result": {
                  "status": "failed",
                  "error_message" : " (RuntimeError)\n./features/step_definitions/steps.rb:4:in `/^this step fails$/'\nfeatures/outline.feature:9:4:in `this step fails'",
		  "duration": 1
                }
              }
            ]
          },
          {
            "id": "an-outline-feature;outline;examples2;2",
            "keyword": "Scenario Outline",
            "name": "outline",
            "line": 13,
            "description": "",
            "type": "scenario",
            "steps": [
              {
                "keyword": "Given ",
                "name": "this step passes",
                "line": 4,
                "match": {
                  "location": "features/step_definitions/steps.rb:1"
                },
                "result": {
                  "status": "passed",
                  "duration": 1
                }
              }
            ]
          }
        ]
      }
    ]

    """

  Scenario: Attaching data directly
    When I run `cucumber --format json -x features/attach_data_directly.feature`
    Then it should pass with JSON:
    """
    [
      {
        "uri": "features/attach_data_directly.feature",
        "id": "an-embed-data-directly-feature",
        "keyword": "Feature",
        "name": "An embed data directly feature",
        "line": 1,
        "description": "",
        "elements": [
          {
            "id": "an-embed-data-directly-feature;",
            "keyword": "Scenario",
            "name": "",
            "line": 3,
            "description": "",
            "type": "scenario",
            "steps": [
              {
                "keyword": "Given ",
                "name": "I attach data directly",
                "line": 4,
                "embeddings": [
                  {
		    "mime_type": "mime-type",
		    "data": "YWJj"
                  }
                ],
                "match": {
                  "location": "features/step_definitions/json_steps.rb:10"
                },
                "result": {
                  "status": "passed",
                  "duration": 1
                }
              }
            ]
          },
          {
            "keyword": "Scenario Outline",
            "name": "",
            "line": 11,
            "description": "",
            "id": "an-embed-data-directly-feature;;;2",
            "type": "scenario",
            "steps": [
              {
                "keyword": "Given ",
                "name": "I attach data directly",
                "line": 7,
                "embeddings": [
                  {
                    "mime_type": "mime-type",
                    "data": "YWJj"
                  }
                ],
                "match": {
                  "location": "features/step_definitions/json_steps.rb:10"
                },
                "result": {
                  "status": "passed",
                  "duration": 1
                }
              }
            ]
          },
          {
            "keyword": "Scenario Outline",
            "name": "",
            "line": 12,
            "description": "",
            "id": "an-embed-data-directly-feature;;;3",
            "type": "scenario",
            "steps": [
              {
                "keyword": "Given ",
                "name": "I attach data directly",
                "line": 7,
                "embeddings": [
                  {
                    "mime_type": "mime-type",
                    "data": "YWJj"
                  }
                ],
                "match": {
                  "location": "features/step_definitions/json_steps.rb:10"
                },
                "result": {
                  "status": "passed",
                  "duration": 1
                }
              }
            ]
          }
        ]
      }
    ]

    """

  Scenario: handle output from hooks
     Given a file named "features/step_definitions/output_steps.rb" with:
      """
      Before do
        log "Before hook 1"
        attach "src", "mime_type"
      end

      Before do
        log "Before hook 2"
        attach "src", "mime_type"
      end

      AfterStep do
        log "AfterStep hook 1"
        attach "src", "mime_type"
      end

      AfterStep do
        log "AfterStep hook 2"
        attach "src", "mime_type"
      end

      After do
        log "After hook 1"
        attach "src", "mime_type"
      end

      After do
        log "After hook 2"
        attach "src", "mime_type"
      end
      """
    When I run `cucumber --format json features/out_scenario_out_scenario_outline.feature`
    Then it should pass

  Scenario: shows a deprecation warning
    When I run `cucumber --format json`
    Then the stderr should contain:
      """
      WARNING: --format=json is deprecated and will be removed after version 5.0.0
      """
    And the stderr should contain:
      """
      Please use --format=message and stand-alone json-formatter.
      """