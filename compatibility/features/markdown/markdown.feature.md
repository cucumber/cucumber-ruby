# Feature: Cheese

This table is not picked up by Gherkin (not indented 2+ spaces)

| foo | bar |
| --- | --- |
| boz | boo |


## Rule: Nom nom nom

I love cheese, especially fromage macaroni cheese. Rubber cheese ricotta caerphilly blue castello who moved my cheese queso bavarian bergkase melted cheese.

### Scenario Outline: Ylajali!

* Given some TypeScript code:
  ```typescript
  type Cheese = 'reblochon' | 'roquefort' | 'rocamadour'
  ```
* And some classic Gherkin:
  ```gherkin
  Given there are 24 apples in Mary's basket
  ```
* When we use a data table and attach something and then <what>
  | name | age |
  | ---- | --: |
  | Bill |   3 |
  | Jane |   6 |
  | Isla |   5 |
* Then this might or might not run

#### Examples: because we need more tables

This table is indented 2 spaces, so Gherkin will pick it up

  | what |
  | ---- |
  | fail |
  | pass |

And oh by the way, this table is also ignored by Gherkin because it doesn't have 2+ space indent:

| cheese   |
| -------- |
| gouda    |
| gamalost |
