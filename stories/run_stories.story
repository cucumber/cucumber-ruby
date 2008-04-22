Story: Run Stories
  As a programmer 
  I want to execute stories 
  So that I can communicate better with stakeholders

  Scenario: Run a passing English story
    Given story file fixture_stories/sell_cucumbers.story
    When I run it
    Then the execution should succeed

  Scenario: Run a failing English story
    Given story file fixture_stories/steal_cucumbers.story
    When I run it
    Then the execution should fail
