Feature: See features
  In order to make Cucumber features more accessible
  I should be able to see the existing features in a system
  
  Scenario: See features as HTML
    Given the feature server is running
    When I visit "/features"
    Then I should see a link to "See features"