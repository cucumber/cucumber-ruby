Feature: Usage of a `Rule`
  You can place scenarios inside rules. This makes it possible to structure Gherkin documents
  in the same way as [example maps](https://cucumber.io/blog/bdd/example-mapping-introduction/).

  You can also use the Examples synonym for Scenario to make them even similar.

  Rule: A sale cannot happen if the customer does not have enough money
    # Unhappy path
    Example: Not enough money
      Given the customer has 100 cents
      And there are chocolate bars in stock
      When the customer tries to buy a 125 cent chocolate bar
      Then the sale should not happen

    # Happy path
    Example: Enough money
      Given the customer has 100 cents
      And there are chocolate bars in stock
      When the customer tries to buy a 75 cent chocolate bar
      Then the sale should happen

  @some-tag
  Rule: a sale cannot happen if there is no stock
    # Unhappy path
    Example: No chocolates left
      Given the customer has 100 cents
      And there are no chocolate bars in stock
      When the customer tries to buy a 1 cent chocolate bar
      Then the sale should not happen
