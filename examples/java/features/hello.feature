Feature: Hello
  In order to have more friends
  I want to say hello

  Scenario: Personal greeting
    Given my name is Aslak
    When I greet David
    Then he should hear Hi, David. I'm Aslak.
    And I should remember David as a friend
    And I should get David's phone number

