Feature: Cucumber command line
  In order to write better software
  Developers should be able to execute requirements as tests

  Scenario: Run single scenario with missing step definition
    When I run cucumber -q features/sample.feature:5
    Then it should pass with      
      """
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

      1 scenario
      1 undefined step

      """

  Scenario: Fail with --strict
    When I run cucumber -q features/sample.feature:5 --strict
    Then it should fail with
      """
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing
            Undefined step: "missing" (Cucumber::Undefined)
            features/sample.feature:6:in `Given missing'

      1 scenario
      1 undefined step

      """

  Scenario: Succeed with --strict
    When I run cucumber -q features/sample.feature:9 --strict
    Then it should pass with
    """
    @one
    Feature: Sample

      @three
      Scenario: Passing
        Given passing
          | a | b |
          | c | d |

    1 scenario
    1 passed step

    """

  Scenario: Specify 2 line numbers where one is a tag
    When I run cucumber -q features/sample.feature:5:14
    Then it should fail with
      """
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

        @four
        Scenario: Failing
          Given failing
            \"\"\"
            hello
            \"\"\"
            FAIL (RuntimeError)
            ./features/step_definitions/sample_steps.rb:2:in `flunker'
            ./features/step_definitions/sample_steps.rb:9:in `/^failing$/'
            features/sample.feature:16:in `Given failing'

      2 scenarios
      1 failed step
      1 undefined step

      """

  Scenario: Require missing step definition from elsewhere
    When I run cucumber -q -r ../../features/step_definitions/extra_steps.rb features/sample.feature:5
    Then it should pass with
      """
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

      1 scenario
      1 passed step

      """

  Scenario: Specify the line number of a row
    When I run cucumber -q features/sample.feature:12
    Then it should pass with
      """
      @one
      Feature: Sample

        @three
        Scenario: Passing
          Given passing
            | a | b |
            | c | d |

      1 scenario
      1 passed step

      """

  Scenario: Run all with progress formatter
    When I run cucumber -q --format progress features/sample.feature
    Then it should fail with
      """
      U.F

      (::) failed steps (::)

      FAIL (RuntimeError)
      ./features/step_definitions/sample_steps.rb:2:in `flunker'
      ./features/step_definitions/sample_steps.rb:9:in `/^failing$/'
      features/sample.feature:16:in `Given failing'

      3 scenarios
      1 failed step
      1 undefined step
      1 passed step

      """

  Scenario: Run Norwegian
    Given I am in i18n/no
    When I run cucumber -q --language no features
    Then it should pass with
      """
      Egenskap: Summering
        For å slippe å gjøre dumme feil
        Som en regnskapsfører
        Vil jeg kunne legge sammen

        Scenario: to tall
          Gitt at jeg har tastet inn 5
          Og at jeg har tastet inn 7
          Når jeg summerer
          Så skal resultatet være 12

        @iterasjon3
        Scenario: tre tall
          Gitt at jeg har tastet inn 5
          Og at jeg har tastet inn 7
          Og at jeg har tastet inn 1
          Når jeg summerer
          Så skal resultatet være 13

      2 scenarios
      9 passed steps

      """

  Scenario: --dry-run
    When I run cucumber --dry-run --no-snippets features/*.feature --tags ~@lots
    Then it should pass with
      """
      Feature: Calling undefined step

        Scenario: Call directly
          Given a step definition that calls an undefined step

        Scenario: Call via another
          Given call step "a step definition that calls an undefined step"

      Feature: Failing expectation

        Scenario: Failing expectation
          Given failing expectation

      Feature: Lots of undefined

        Scenario: Implement me
          Given it snows in Sahara
          Given it's 40 degrees in Norway
          And it's 40 degrees in Norway
          When I stop procrastinating
          And there is world peace

      Feature: Outline Sample

        Scenario: I have no steps

        Scenario Outline: Test state
          Given <state> without a table
          Given <other_state> without a table

        Examples: Rainbow colours
          | state   | other_state |
          | missing | passing     |
          | passing | passing     |
          | failing | passing     |

        Examples: Only passing
          | state   | other_state |
          | passing | passing     |

      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

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

      12 scenarios
      12 skipped steps
      7 undefined steps

      """

  Scenario: Multiple formatters and outputs
    When I run cucumber --format progress --out tmp/progress.txt --format pretty --out tmp/pretty.txt  --dry-run features/lots_of_undefined.feature
    And examples/self_test/tmp/progress.txt should contain
      """
      UUUUU

      1 scenario
      5 undefined steps

      """
    And examples/self_test/tmp/pretty.txt should match
      """
      Feature: Lots of undefined

        Scenario: Implement me
          Given it snows in Sahara
          Given it's 40 degrees in Norway
          And it's 40 degrees in Norway
          When I stop procrastinating
          And there is world peace

      1 scenario
      5 undefined steps

      """

  Scenario: Run scenario specified by name using --scenario
    When I run cucumber --scenario Passing -q features
    Then it should pass with
      """
      @one
      Feature: Sample

        @three
        Scenario: Passing
          Given passing
            | a | b |
            | c | d |

      1 scenario
      1 passed step

      """

  Scenario: Run with a tag that exists on 2 scenarios
    When I run cucumber -q features --tags three
    Then it should pass with
      """
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

        @three
        Scenario: Passing
          Given passing
            | a | b |
            | c | d |

      2 scenarios
      1 undefined step
      1 passed step

      """

  Scenario: Run with a tag that exists on 1 feature
    When I run cucumber -q features --tags one
    Then it should fail with
      """
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

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
            FAIL (RuntimeError)
            ./features/step_definitions/sample_steps.rb:2:in `flunker'
            ./features/step_definitions/sample_steps.rb:9:in `/^failing$/'
            features/sample.feature:16:in `Given failing'

      3 scenarios
      1 failed step
      1 undefined step
      1 passed step

      """

  Scenario: Run with a negative tag
    When I run cucumber -q features/sample.feature --dry-run -t ~four
    Then it should pass with
      """
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

        @three
        Scenario: Passing
          Given passing
            | a | b |
            | c | d |

      2 scenarios
      1 skipped step
      1 undefined step

      """

  Scenario: Reformat files with --autoformat
    When I run cucumber --autoformat tmp/formatted features
    Then examples/self_test/tmp/formatted/features/sample.feature should contain
      """
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

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

