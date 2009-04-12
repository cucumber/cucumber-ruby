@pending

Feature: Rake task
  In order to ease the development process
  As a developer and CI server administrator
  Cucumber features should be executable via Rake

  Scenario: Run rake task with a defined profile
    Given a standard Cucumber project directory structure
    And a file named "features/missing_step_definitions.feature" with:
    """
    Feature: Sample

      Scenario: Wanted
        Given I want to run this

      Scenario: Unwanted
        Given I don't want this ran
    """
    And the following profile is defined:
    """
    foo: --quiet --no-color features/single_scenario_with_missing_step_definition.feature:3"
    """
    And a file named "Rakefile" with:
    """
    $LOAD_PATH.unshift(CUCUMBER_LIB)
    require 'cucumber/rake/task'

    Cucumber::Rake::Task.new(:features) do |t|
      t.profile = "foo"
    end
    """

    When I run rake features
    Then it should pass with
      """
      Feature: Sample

        Scenario: Wanted
          Given I want to run this

      1 scenario
      1 undefined step

      """

