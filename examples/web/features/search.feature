Feature: Search
  As an information seeker
  I want to find more information
  So that I can learn more

  Scenario: Find what I'm looking for
    Given I am on the Google search page
    When I search for "rspec"
    Then I should see a link to "RSpec-1.1.4: Overview":http://rspec.info/
