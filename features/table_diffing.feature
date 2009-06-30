Feature: Table diffing
  In order to more easily compare data in tables
  step definition writers should be able to diff
  a table with expected data and see the diff inline
  
  Scenario: Extra row
    Given a standard Cucumber project directory structure
    And a file named "features/tables.feature" with:
      """
      Feature: Tables
        Scenario: Extra row
          Then the table should be:
            | x | y |
            | a | b |
            | c | d |
            | e | f |
            | g | h |
            | i | j |
            | k | l |
      """
    And a file named "features/step_definitions/table_steps.rb" with:
      """
      Then /the table should be:/ do |expected|
        expected.diff!(table(%{
          | x | y | z |
          | 1 | 2 | A |
          | a | b | B |
          | i | j | C |
          | 3 | 4 | D |
          | k | l | E |
        }))
      end
      """
    When I run cucumber -i features/tables.feature
    Then it should fail with
      """
      Feature: Tables
      
        Scenario: Extra row         # features/tables.feature:2
          Then the table should be: # features/step_definitions/table_steps.rb:1
            | x | y | z |
          + | 1 | 2 | A |
            | a | b | B |
          - | c | d |   |
          - | e | f |   |
          - | g | h |   |
            | i | j | C |
          + | 3 | 4 | D |
            | k | l | E |
            Tables were not identical (RuntimeError)
            ./features/step_definitions/table_steps.rb:2:in `/the table should be:/'
            features/tables.feature:3:in `Then the table should be:'
      
      Failing Scenarios:
      cucumber features/tables.feature:2 # Scenario: Extra row

      1 scenario (1 failed)
      1 step (1 failed)

      """
