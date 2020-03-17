Feature: Tag logic
  In order to conveniently run subsets of features
  As a Cuker
  I want to select features using logical AND/OR of tags

  Background:
    Given a file named "features/test.feature" with:
      """
      @feature
      Feature: Sample

        @one @three
        Scenario: Example
          Given passing

        @one
        Scenario: Another Example
          Given passing

        @three
        Scenario: Yet another Example
          Given passing

        @ignore
        Scenario: And yet another Example
          Given passing
      """

  Scenario: ANDing tags
    When I run `cucumber -q -t '@one and @three' features/test.feature`
    Then it should pass with:
      """
      @feature
      Feature: Sample

        @one @three
        Scenario: Example
          Given passing

      1 scenario (1 undefined)
      1 step (1 undefined)

      """

  Scenario: ORing tags
    When I run `cucumber -q -t '@one or @three' features/test.feature`
    Then it should pass with:
      """
      @feature
      Feature: Sample

        @one @three
        Scenario: Example
          Given passing

        @one
        Scenario: Another Example
          Given passing

        @three
        Scenario: Yet another Example
          Given passing

      3 scenarios (3 undefined)
      3 steps (3 undefined)

      """

  Scenario: Negative tags
    When I run `cucumber -q -t 'not @three' features/test.feature`
    Then it should pass with:
      """
      @feature
      Feature: Sample

        @one
        Scenario: Another Example
          Given passing

        @ignore
        Scenario: And yet another Example
          Given passing

      2 scenarios (2 undefined)
      2 steps (2 undefined)
      """

  Scenario: Run with limited tag count, blowing it on scenario
     When I run `cucumber -q --no-source --tags @one:1 features/test.feature`
     Then it fails before running features with:
       """
       @one occurred 2 times, but the limit was set to 1
         features/test.feature:5
         features/test.feature:9
       """

  Scenario: Run with limited tag count, blowing it via feature inheritance
     When I run `cucumber -q --no-source --tags @feature:1 features/test.feature`
     Then it fails before running features with:
       """
       @feature occurred 4 times, but the limit was set to 1
         features/test.feature:5
         features/test.feature:9
         features/test.feature:13
         features/test.feature:17
       """

  Scenario: Run with limited tag count using negative tag, blowing it via a tag that is not run
     When I run `cucumber -q --no-source --tags 'not @one:1' features/test.feature`
     Then it fails before running features with:
       """
       @one occurred 2 times, but the limit was set to 1
       """

  Scenario: Limiting with tags which do not exist in the features
    Originally added to check [Lighthouse bug #464](https://rspec.lighthouseapp.com/projects/16211/tickets/464).

    When I run `cucumber -q -t @i_dont_exist features/test.feature`
    Then it should pass
