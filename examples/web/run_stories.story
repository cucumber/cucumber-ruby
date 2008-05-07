Story: Run Stories
  As an information seeker
  I want to find more information
  So that I can learn more

  Scenario: Find what I'm looking for
    Given I am on the search page
    And I have entered "rspec"
    When I search
    Then I should see a link to "RSpec-1.1.3: Overview":http://rspec.info
