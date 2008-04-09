Story: Sell stories
  As a stories artist
  I want to sell stories
  So that I can make the world a better place
  
  Scenario: Sell a couple
    Given there are 5 stories
    When I sell 2 stories
    Then there should be 3 stories left
