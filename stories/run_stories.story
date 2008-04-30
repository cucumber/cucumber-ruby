Story: Run Stories
  As a programmer 
  I want to execute stories 
  So that I can communicate better with stakeholders

  Scenario: Run a passing story
    Given I have some failing steps
    When I run a story
    Then the execution should fail

  Scenario: Run a failing story
    Given I have only passing steps
    When I run a story
    Then the execution should pass
