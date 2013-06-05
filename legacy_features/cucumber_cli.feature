Feature: Cucumber command line
  In order to write better software
  Developers should be able to execute requirements as tests

  Scenario: Multiple formatters and outputs
    When I run cucumber --format progress --out tmp/progress.txt --format pretty --out tmp/pretty.txt --no-source --dry-run --no-snippets features/lots_of_undefined.feature
    Then STDERR should be empty
    Then "fixtures/self_test/tmp/progress.txt" should contain
      """
      UUUUU

      1 scenario (1 undefined)
      5 steps (5 undefined)

      """
    And "fixtures/self_test/tmp/pretty.txt" should contain
      """
      Feature: Lots of undefined

        Scenario: Implement me
          Given it snows in Sahara
          Given it's 40 degrees in Norway
          And it's 40 degrees in Norway
          When I stop procrastinating
          And there is world peace
      
      1 scenario (1 undefined)
      5 steps (5 undefined)

      """

  Scenario: Run feature elements which matches a name using --name
    When I run cucumber --name Pisang -q features/
    Then it should pass with
      """
      Feature: search examples

        Background: Hantu Pisang background match
          Given passing without a table

        Scenario: should match Hantu Pisang
          Given passing without a table

        Scenario Outline: Hantu Pisang match
          Given <state> without a table

          Examples: 
            | state   |
            | passing |

        Scenario Outline: no match in name but in examples
          Given <state> without a table

          Examples: Hantu Pisang
            | state   |
            | passing |

      3 scenarios (3 passed)
      6 steps (6 passed)

      """

  Scenario: Reformat files with --autoformat
    When I run cucumber --autoformat tmp/formatted features
    Then STDERR should be empty
    Then "fixtures/self_test/tmp/formatted/features/sample.feature" should contain
      """
      # Feature comment
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

        # Scenario comment
        @three
        Scenario: Passing
          Given passing
            | a | b |
            | c | d |

        @four
        Scenario: Failing
          Given failing
            \"\"\"
            hello
            \"\"\"


      """

  Scenario: Run feature elements which match a name using -n
    When I run cucumber -n Pisang -q features/
    Then STDERR should be empty
    Then it should pass with
      """
      Feature: search examples

        Background: Hantu Pisang background match
          Given passing without a table

        Scenario: should match Hantu Pisang
          Given passing without a table

        Scenario Outline: Hantu Pisang match
          Given <state> without a table

          Examples: 
            | state   |
            | passing |

        Scenario Outline: no match in name but in examples
          Given <state> without a table

          Examples: Hantu Pisang
            | state   |
            | passing |

      3 scenarios (3 passed)
      6 steps (6 passed)

      """
