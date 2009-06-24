Feature: Profiles
  In order to save time and prevent carpal tunnel syndrome
  Cucumber users can save and reuse commonly used cucumber flags in a 'cucumber.yml' file.
  These named arguments are called profiles and the yml file should be in the root of your project.
  Any cucumber argument is valid in a profile.  To see all the available flags type 'cucumber --help'
  For more information about profiles please see the wiki:
  http://wiki.github.com/aslakhellesoy/cucumber/cucumberyml

  Background: Basic App
    Given a standard Cucumber project directory structure
    And a file named "features/sample.feature" with:
      """
      Feature: Sample
        Scenario: this is a test
          Given I am just testing stuff
      """
    And a file named "features/support/env.rb"
    And a file named "features/support/super_env.rb"
    And the following profiles are defined:
      """
      default: features/sample.feature --require support/env.rb -v
      super: features/sample.feature --require support/super_env.rb -v
      """

  Scenario: Explicitly defining a profile to run
    When I run cucumber features/sample.feature --profile super
    Then the output should contain
      """
      Using the super profile...
      """
    And exactly these files should be loaded: support/super_env.rb

  Scenario: Defining multiple profiles to run
    When I run cucumber features/sample.feature --profile default --profile super
    Then the output should contain
      """
      Using the default and super profiles...
      """
    And exactly these files should be loaded: support/env.rb, support/super_env.rb

  Scenario: no profile declared with a default profile passed in
    When I run cucumber -v
    Then the default profile should be used
    And exactly these files should be loaded: support/env.rb

  @in-progress
  Scenario: missing profile
    When I run cucumber -p foo
    Then STDERR should be
      """
      Could not find profile: 'foo'

      Defined profiles in cucumber.yml:
        * default
        * wip
      """
