Feature: Publish banner

  A banner is displayed on stderr at the end of a run to inform that reports can
  be published on reports.cucumber.io[reports.cucumber.io](https://reports.cucumber.io).

  Scenario: Banner is displayed when running Cucumber
    Given a file named "features/hello.feature" with:
    """
    Feature: Hello
    """
    When I run `cucumber`
    Then the output should contain:
    """
    ┌──────────────────────────────────────────────────────────────────────────┐
    │ Share your Cucumber Report with your team at https://reports.cucumber.io │
    │                                                                          │
    │ Command line option:    --publish                                        │
    │ Environment variable:   CUCUMBER_PUBLISH_ENABLED=true                    │
    │ cucumber.yml:           default: --publish                               │
    │                                                                          │
    │ More information at https://reports.cucumber.io/docs/cucumber-ruby       │
    │                                                                          │
    │ To disable this message, specify CUCUMBER_PUBLISH_QUIET=true or use the  │
    │ --no-publish-ad option. You can also add this to your cucumber.yml:      │
    │ default: --no-publish-ad                                                 │
    └──────────────────────────────────────────────────────────────────────────┘
    """

  Scenario: Banner is not displayed when using --no-publish-ad
    Given a file named "features/hello.feature" with:
    """
    Feature: Hello
    """
    When I run `cucumber --no-publish-ad`
    Then the output should not contain:
    """
    Share your Cucumber Report with your team at https://reports.cucumber.io
    """
