Feature: Attachments
  It is sometimes useful to take a screenshot while a scenario runs.
  Or capture some logs.

  Cucumber lets you `attach` arbitrary files during execution, and you can
  specify a media type for the contents.

  Formatters can then render these attachments in reports.

  Background:
    Given a file named "features/attaching_screenshot_with_mediatype.feature" with:
      """
      Feature: A screenshot feature
        Scenario:
          Given I attach a screenshot with media type
      """
    Given a file named "features/attaching_screenshot_without_mediatype.feature" with:
      """
      Feature: A file feature
        Scenario:
          Given I attach a screenshot without media type
      """
    And a file named "features/screenshot.png" with:
      """
      foo
      """
    And a file named "features/step_definitions/attaching_screenshot_steps.rb" with:
      """
      Given /^I attach a screenshot with media type/ do
        attach "features/screenshot.png", "image/png"
      end

      Given /^I attach a screenshot without media type/ do
        attach "features/screenshot.png"
      end
      """

  Scenario: Files can be attached given their path
    When I run `cucumber --format message features/attaching_screenshot_with_mediatype.feature`
    Then output should be valid NDJSON
    And the output should contain NDJSON with key "attachment"
    And the output should contain NDJSON with key "body" and value "Zm9v"
    And the output should contain NDJSON with key "mediaType" and value "image/png"
    
  Scenario: Media type is inferred from the given file
    When I run `cucumber --format message features/attaching_screenshot_without_mediatype.feature`
    Then output should be valid NDJSON
    And the output should contain NDJSON with key "attachment"
    And the output should contain NDJSON with key "body" and value "Zm9v"
    And the output should contain NDJSON with key "mediaType" and value "image/png"
    
  Scenario: With json formatter, files can be attached given their path
    When I run `cucumber --format json features/attaching_screenshot_with_mediatype.feature`
    Then the output should contain "embeddings\":[{\"mime_type\":\"image/png\",\"data\":\"Zm9v\"}]"
