Feature: JUnit output formatter
  In order for developers to create test reports with ant
  Cucumber should be able to output JUnit xml files

  Background:
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Given(/passing/) { }
      Given(/failing/) { raise }
      Given(/pending/) { pending }
      """
    And a file named "features/test.feature" with:
      """
      Feature: One passing scenario, one failing scenario

        Scenario: Passing
          Given passing

        Scenario: Failing
          Given failing
      """
    And a file named "features/pending.feature" with:
      """
      Feature: Pending and undefined
        Scenario: Pending
          Given pending
        Scenario: Undefined
          Given undefined
      """

  Scenario: one feature, one passing scenario, one failing scenario
    When I run `cucumber --format junit --out tmp/ features/test.feature`
    And the junit run with output "tmp/TEST-features-test.xml" took "0.005" seconds
    Then it should fail with:
      """

      """
    And the file "tmp/TEST-features-test.xml" should contain:
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite errors="0" failures="1" name="One passing scenario, one failing scenario" skipped="0" tests="2" time="0.005">
      <testcase classname="One passing scenario, one failing scenario" name="Passing" time="0.005">
        <system-out/>
        <system-err/>
      </testcase>
      <testcase classname="One passing scenario, one failing scenario" name="Failing" time="0.005">
        <failure message="failed Failing" type="failed">
          <![CDATA[Scenario: Failing

      Given failing

      Message:
      ]]>
          <![CDATA[ (RuntimeError)
      ./tmp/aruba/features/step_definitions/steps.rb:2:in `/failing/'
      features/test.feature:7:in `Given failing']]>
        </failure>
        <system-out/>
        <system-err/>
      </testcase>
        <system-out>
          <![CDATA[]]>
        </system-out>
        <system-err>
          <![CDATA[]]>
        </system-err>
      </testsuite>
      """

  Scenario: one feature in a subdirectory, one passing scenario, one failing scenario
    Given a file named "features/some_subdirectory/test.feature" with:
      """
      Feature: Subdirectory - One passing scenario, one failing scenario

        Scenario: Passing
          Given passing

        Scenario: Failing
          Given failing
      """
    When I run `cucumber --format junit --out tmp/ features/some_subdirectory/test.feature --require features`
    And the junit run with output "tmp/TEST-features-some_subdirectory-test.xml" took "0.005" seconds
    Then it should fail with:
      """

      """
    And the file "tmp/TEST-features-some_subdirectory-test.xml" should contain:
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite errors="0" failures="1" name="Subdirectory - One passing scenario, one failing scenario" skipped="0" tests="2" time="0.005">
      <testcase classname="Subdirectory - One passing scenario, one failing scenario" name="Passing" time="0.005">
        <system-out/>
        <system-err/>
      </testcase>
      <testcase classname="Subdirectory - One passing scenario, one failing scenario" name="Failing" time="0.005">
        <failure message="failed Failing" type="failed">
          <![CDATA[Scenario: Failing

      Given failing

      Message:
      ]]>
          <![CDATA[ (RuntimeError)
      ./tmp/aruba/features/step_definitions/steps.rb:2:in `/failing/'
      features/some_subdirectory/test.feature:7:in `Given failing']]>
        </failure>
        <system-out/>
        <system-err/>
      </testcase>
        <system-out>
          <![CDATA[]]>
        </system-out>
        <system-err>
          <![CDATA[]]>
        </system-err>
      </testsuite>
      """

  Scenario: pending and undefined steps are reported as skipped
    When I run `cucumber --format junit --out tmp/ features/pending.feature`
    And the junit run with output "tmp/TEST-features-pending.xml" took "0.009" seconds
    Then it should pass with:
      """

      """
    And the file "tmp/TEST-features-pending.xml" should contain:
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite errors="0" failures="0" name="Pending and undefined" skipped="2" tests="2" time="0.009">
      <testcase classname="Pending and undefined" name="Pending" time="0.009">
        <skipped/>
        <system-out/>
        <system-err/>
      </testcase>
      <testcase classname="Pending and undefined" name="Undefined" time="0.009">
        <skipped/>
        <system-out/>
        <system-err/>
      </testcase>
        <system-out>
          <![CDATA[]]>
        </system-out>
        <system-err>
          <![CDATA[]]>
        </system-err>
      </testsuite>
      """

  Scenario: pending and undefined steps with strict option should fail
    When I run `cucumber --format junit --out tmp/ features/pending.feature --strict`
    And the junit run with output "tmp/TEST-features-pending.xml" took "0.009" seconds
    Then it should fail with:
      """

      """
    And the file "tmp/TEST-features-pending.xml" should contain:
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite errors="0" failures="2" name="Pending and undefined" skipped="0" tests="2" time="0.009">
      <testcase classname="Pending and undefined" name="Pending" time="0.009">
        <failure message="pending Pending" type="pending">
          <![CDATA[Scenario: Pending

      ]]>
          <![CDATA[TODO (Cucumber::Pending)
      ./tmp/aruba/features/step_definitions/steps.rb:3:in `/pending/'
      features/pending.feature:3:in `Given pending']]>
        </failure>
        <system-out/>
        <system-err/>
      </testcase>
      <testcase classname="Pending and undefined" name="Undefined" time="0.009">
        <failure message="undefined Undefined" type="undefined">
          <![CDATA[Scenario: Undefined

      ]]>
          <![CDATA[Undefined step: "undefined" (Cucumber::Undefined)
      features/pending.feature:5:in `Given undefined']]>
        </failure>
        <system-out/>
        <system-err/>
      </testcase>
        <system-out>
          <![CDATA[]]>
        </system-out>
        <system-err>
          <![CDATA[]]>
        </system-err>
      </testsuite>
      """

  Scenario: run all features
    When I run `cucumber --format junit --out tmp/ features`
    Then it should fail with:
      """

      """
    And the following files should exist:
      | tmp/TEST-features-test.xml    |
      | tmp/TEST-features-pending.xml |

  Scenario: shows error message if no --out is passed
    When I run `cucumber --format junit features`
    Then the stderr should contain:
      """
      You *must* specify --out DIR for the junit formatter
      """

  Scenario: one feature, one scenario outline, two examples: one passing, one failing
    Given a file named "features/scenario_outline.feature" with:
      """
      Feature: Scenario outlines

        Scenario Outline: Using scenario outlines
          Given a <type> scenario

          Examples:
            | type    |
            | passing |
            | failing |
      """
    When I run `cucumber --format junit --out tmp/ features/scenario_outline.feature`
    And the junit run with output "tmp/TEST-features-scenario_outline.xml" took "0.005" seconds
    Then it should fail with:
      """

      """
    And the file "tmp/TEST-features-scenario_outline.xml" should contain:
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite errors="0" failures="1" name="Scenario outlines" skipped="0" tests="2" time="0.005">
      <testcase classname="Scenario outlines" name="Using scenario outlines (outline example : | passing |)" time="0.005">
        <system-out/>
        <system-err/>
      </testcase>
      <testcase classname="Scenario outlines" name="Using scenario outlines (outline example : | failing |)" time="0.005">
        <failure message="failed Using scenario outlines (outline example : | failing |)" type="failed">
          <![CDATA[Scenario Outline: Using scenario outlines

      Example row: | failing |

      Message:
      ]]>
          <![CDATA[ (RuntimeError)
      ./tmp/aruba/features/step_definitions/steps.rb:2:in `/failing/'
      features/scenario_outline.feature:4:in `Given a <type> scenario']]>
        </failure>
        <system-out/>
        <system-err/>
      </testcase>
        <system-out>
          <![CDATA[]]>
        </system-out>
        <system-err>
          <![CDATA[]]>
        </system-err>
      </testsuite>
      """
