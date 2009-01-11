Feature: Run single scenario
  In order to speed up development
  Developers should be able to run just a single scenario
  
  Scenario: Run single scenario with missing step definition
    When I run cucumber -q features/sample.feature:3
    Then the output should be
      """
      Feature: Sample
        Scenario: Missing
          Given missing


      1 scenario
      1 step pending (1 with no step definition)
      
      """
      
  Scenario: Run single failing scenario
    When I run cucumber -q features/sample.feature:12
    Then the output should be
      """
      Feature: Sample
        Scenario: Failing
          Given failing
            FAIL (RuntimeError)
            ./features/step_definitions/sample_steps.rb:5:in `Given /^failing$/'
            features/sample.feature:12:in `Given failing'


      1 scenario
      1 step failed

      """

  Scenario: Specify 2 line numbers
    When I run cucumber -q features/sample.feature:3:12
    Then the output should be
      """
      Feature: Sample
        Scenario: Missing
          Given missing

        Scenario: Failing
          Given failing
            FAIL (RuntimeError)
            ./features/step_definitions/sample_steps.rb:5:in `Given /^failing$/'
            features/sample.feature:12:in `Given failing'


      2 scenarios
      1 step failed
      1 step pending (1 with no step definition)

      """


  Scenario: Require missing step definition from elsewhere
    When I run cucumber -q -r ../../features/step_definitions/extra_steps.rb features/sample.feature:3
    Then the output should be
      """
      Feature: Sample
        Scenario: Missing
          Given missing


      1 scenario
      1 step passed

      """
      
  Scenario: Specify the line number of a blank line
    When I run cucumber -q features/sample.feature:10
    Then the output should be
      """
      Feature: Sample
        Scenario: Passing
          Given passing


      1 scenario
      1 step passed

      """

  Scenario: Specify the line number of a row
    When I run cucumber -q features/sample.feature:8
    Then the output should be
      """
      Feature: Sample
        Scenario: Passing
          Given passing


      1 scenario
      1 step passed

      """

  Scenario: Run all with progress formatter
    When I run cucumber -q --format progress features/sample.feature
    Then the output should be
      """
      P.F

      Pending Scenarios:
      
      1)  Sample (Missing)
      
      
      Failed:
      
      1)
      FAIL
      ./features/step_definitions/sample_steps.rb:5:in `Given /^failing$/'
      features/sample.feature:12:in `Given failing'

      """

    Scenario: Run Norwegian
      Given I am in i18n/no
      When I run cucumber -q --language no features
      Then the output should be
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

          Scenario: tre tall
            Gitt at jeg har tastet inn 5
            Og at jeg har tastet inn 7
            Og at jeg har tastet inn 1
            Når jeg summerer
            Så skal resultatet være 13


        2 scenarios
        9 steps passed

        """
