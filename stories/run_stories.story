Story: Run Stories
  As a programmer 
  I want to execute stories 
  So that I can communicate better with stakeholders

  Scenario: Run a failing English story
    Given story file stories/fixtures/english
    When I run it without arguments
    Then there should be 2 passing scenarios
    Then there should be 6 passing steps

  Scenario: Sell a dozen
    Given there are 5 cucumber
    When I sell 12 cucumbers
    Then I should owe 7 cucumbers
