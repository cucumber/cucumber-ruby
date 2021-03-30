Feature: Attachments
  It is sometimes useful to take a screenshot while a scenario runs.
  Or capture some logs.

  Cucumber lets you `attach` arbitrary files during execution, and you can
  specify a media type for the contents.

  Formatters can then render these attachments in reports.

  Attachments must have a body and a media type

  Background:
    Given a file named "features/attaching_screenshot.feature" with:
      """
      Feature: A screenshot feature

        Scenario:
          Given I attach a screenshot

      """
    And a file named "features/screenshot.png" with:
      """
      foo
      """
    And a file named "features/step_definitions/attaching_screenshot_steps.rb" with:
      """
      Given /^I attach a screenshot/ do
        attach "features/screenshot.png", "image/png"
      end
      """

  Scenario: Files can be attached given their path using messages
    When I run `cucumber --format message features/attaching_screenshot.feature`
    Then output should be valid NDJSON
    And the output should contain NDJSON with key "attachment"
    And the output should contain NDJSON with key "body" and value "Zm9v"
    
  Scenario: Files can be attached given their path in json formatter
    When I run `cucumber --format json features/attaching_screenshot.feature`
    Then the output should contain "embeddings\":[{\"mime_type\":\"image/png\",\"data\":\"Zm9v\"}]"
