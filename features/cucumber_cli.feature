Feature: Cucumber command line
  In order to write better software
  Developers should be able to execute requirements as tests
  
  Scenario: Run single scenario with missing step definition
    When I run cucumber -q features/sample.feature:3
    Then it should pass with
      """
      Feature: Sample

        Scenario: Missing
          Given missing

      1 scenario
      1 step undefined
      
      """
      
  Scenario: Run single failing scenario
    When I run cucumber -q features/sample.feature:12
    Then it should fail with
      """
      Feature: Sample

        Scenario: Failing
          Given failing
            expected 1 block argument(s), got 0 (Cucumber::ArityMismatchError)
            ../../bin/../lib/cucumber/core_ext/instance_exec.rb:15:in `/^failing$/'
            features/sample.feature:12:in `Given failing'

      1 scenario
      1 step failed

      """

  Scenario: Specify 2 line numbers
    When I run cucumber -q features/sample.feature:3:12
    Then it should fail with
      """
      Feature: Sample

        Scenario: Missing
          Given missing

        Scenario: Failing
          Given failing
            | e | f |
            | g | h |
            FAIL (RuntimeError)
            ./features/step_definitions/sample_steps.rb:2:in `flunker'
            ./features/step_definitions/sample_steps.rb:9:in `/^failing$/'
            features/sample.feature:12:in `Given failing'

      2 scenarios
      1 step failed
      1 step undefined

      """


  Scenario: Require missing step definition from elsewhere
    When I run cucumber -q -r ../../features/step_definitions/extra_steps.rb features/sample.feature:3
    Then it should pass with
      """
      Feature: Sample

        Scenario: Missing
          Given missing

      1 scenario
      1 step passed

      """
      
  Scenario: Specify the line number of a blank line
    When I run cucumber -q features/sample.feature:10
    Then it should pass with
      """
      Feature: Sample

        Scenario: Passing
          Given passing

      1 scenario
      1 step passed

      """

  Scenario: Specify the line number of a row
    When I run cucumber -q features/sample.feature:8
    Then it should pass with
      """
      Feature: Sample

        Scenario: Passing
          Given passing
            | a | b |
            | c | d |

      1 scenario
      1 step passed

      """

  Scenario: Run all with progress formatter
    When I run cucumber -q --format progress features/sample.feature
    Then it should fail with
      """
      U.F

      (::) undefined (::)

      features/sample.feature:4:in `Given missing'

      (::) failed (::)

      expected 1 block argument(s), got 0 (Cucumber::ArityMismatchError)
      features/step_definitions/sample_steps.rb:8:in `/^failing$/'
      features/sample.feature:12:in `Given failing'

      3 scenarios
      1 step failed
      1 step undefined
      1 step passed

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
      9 steps passed

      """

  Scenario: --dry-run
    When I run cucumber --dry-run features
    Then it should pass with
      """
      Feature: Calling undefined step

        Scenario: Call directly                                # features/call_undefined_step_from_step_def.feature:3
          Given a step definition that calls an undefined step # features/step_definitions/sample_steps.rb:19

        Scenario: Call via another                                         # features/call_undefined_step_from_step_def.feature:6
          Given call step "a step definition that calls an undefined step" # features/step_definitions/sample_steps.rb:23

      Feature: Outline Sample

        Scenario: I have no steps # features/outline_sample.feature:3

        Scenario Outline: Test state          # features/outline_sample.feature:5
          Given <state> without a table
          Given <other_state> without a table

        Examples: 
          | state   | other_state |
          | missing | passing     |
          | passing | passing     |
          | failing | passing     |

      Feature: Sample

        Scenario: Missing # features/sample.feature:3
          Given missing

        Scenario: Passing # features/sample.feature:6
          Given passing   # features/step_definitions/sample_steps.rb:5
            | a | b |
            | c | d |

        Scenario: Failing # features/sample.feature:11
          Given failing   # features/step_definitions/sample_steps.rb:8

      9 scenarios
      9 steps skipped
      2 steps undefined

      """

  Scenario: Multiple formatters and outputs
    When I run cucumber --format progress --out tmp/progress.txt --format html --out tmp/features.html features
    And examples/self_test/tmp/progress.txt should contain
      """
      P.FP.F

      Pending Scenarios:

      1)  Outline Sample (Test state)
      2)  Sample (Missing)


      Failed:

      1)
      FAIL
      ./features/step_definitions/sample_steps.rb:12:in ` /^failing without a table$/'
      features/outline_sample.feature:9:in `/^failing without a table$/'

      2)
      FAIL
      ./features/step_definitions/sample_steps.rb:5:in `Given /^failing$/'
      features/sample.feature:12:in `Given failing'

      """
    And examples/self_test/tmp/features.html should match
      """
      Given passing
      """
      
  Scenario: Run scenario specified by name using --scenario
    When I run cucumber --scenario Passing -q features/sample.feature
    Then it should pass with
      """
      Feature: Sample
        Scenario: Passing
          Given passing


      1 scenario
      1 step passed

      """
