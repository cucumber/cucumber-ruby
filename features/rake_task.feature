Feature: Rake task
  In order to ease the development process
  As a developer and CI server administrator
  Cucumber features should be executable via Rake

  Background:
    Given a standard Cucumber project directory structure
    And a file named "features/missing_step_definitions.feature" with:
      """
      Feature: Sample

        Scenario: Wanted
          Given I want to run this

        Scenario: Unwanted
          Given I don't want this ran
      """


  Scenario: rake task with a defined profile
    Given the following profile is defined:
      """
      foo: --quiet --no-color features/missing_step_definitions.feature:3
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
    Then it should pass
    And the output should contain
      """
      Feature: Sample

        Scenario: Wanted
          Given I want to run this

      1 scenario (1 undefined)
      1 step (1 undefined)
      """

  Scenario: rake task with a defined profile and cucumber_opts
    Given the following profile is defined:
      """
      bar: ['features/missing_step_definitions.feature:3']
      """
    And a file named "Rakefile" with:
      """
      $LOAD_PATH.unshift(CUCUMBER_LIB)
      require 'cucumber/rake/task'

      Cucumber::Rake::Task.new(:features) do |t|
        t.profile = "bar"
        t.cucumber_opts = %w{--quiet --no-color}
      end
      """
    When I run rake features
    Then it should pass
    And the output should contain
      """
      Feature: Sample

        Scenario: Wanted
          Given I want to run this

      1 scenario (1 undefined)
      1 step (1 undefined)
      """

  Scenario: rake task with a defined profile and feature list
    Given a file named "features/the_one_i_want_to_run.feature" with:
      """
      Feature: Desired

        Scenario: Something
          Given this is missing
      """
    Given the following profile is defined:
      """
      baz: ['--quiet', '--no-color']
      """
    And a file named "Rakefile" with:
      """
      $LOAD_PATH.unshift(CUCUMBER_LIB)
      require 'cucumber/rake/task'

      Cucumber::Rake::Task.new(:features) do |t|
        t.profile = "baz"
        t.feature_list = ['features/the_one_i_want_to_run.feature']
      end
      """
    When I run rake features
    Then it should pass
    And the output should contain
      """
      Feature: Desired

        Scenario: Something
          Given this is missing

      1 scenario (1 undefined)
      1 step (1 undefined)
      """

  Scenario: deprecation warnings
    Given a file named "Rakefile" with:
      """
      $LOAD_PATH.unshift(CUCUMBER_LIB)
      require 'cucumber/rake/task'

      Cucumber::Rake::Task.new(:features) do |t|
        t.feature_list = ['features/missing_step_definitions.feature']
      end
      """
    When I run rake features
    Then it should pass
    And STDERR should match
      """
      Cucumber::Rake::Task#feature_list is deprecated and will be removed in 0.4.0.  Please use profiles for complex settings: http://wiki.github.com/aslakhellesoy/cucumber/using-rake#profiles
      """

  Scenario: respect requires
    Given a file named "features/support/env.rb"
    And a file named "features/support/dont_require_me.rb"
    And the following profile is defined:
      """
      no_bomb: features/missing_step_definitions.feature:3 --require features/support/env.rb --verbose
      """
    And a file named "Rakefile" with:
      """
      $LOAD_PATH.unshift(CUCUMBER_LIB)
      require 'cucumber/rake/task'

      Cucumber::Rake::Task.new(:features) do |t|
        t.profile = "no_bomb"
        t.cucumber_opts = %w{--quiet --no-color}
      end
      """

    When I run rake features
    Then it should pass
    And the output should not contain
      """
        * features/support/dont_require_me.rb
      """
