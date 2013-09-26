Feature: Table mapping

  When using the `map_headers!` and `map_column!` methods to change the
  labels in our step definition code, the table output when cucumber is
  run is unchanged. This ensures that readers of the feature output who
  aren't familiar with code aren't confused by what they see.

  @spawn
  Scenario:
    Given a file named "features/f.feature" with:
      """
      Feature: with table
        Scenario:
          Given a table:
            | who   |
            | aslak |
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given(/a table:/) { |table| table.map_headers!(/who/i => 'Who')
        table.map_column!('Who') { |who| "Cuke" }
        table.hashes[0]['Who'] = "Joe"
        table.hashes.should == [{"Who"=>"Joe"}]
      }
      """
    When I run `cucumber features/f.feature`
    Then the stderr should contain a warning message
    And it should pass with:
      """
      Feature: with table

        Scenario:        # features/f.feature:2
          Given a table: # features/step_definitions/steps.rb:1
            | who   |
            | aslak |

      1 scenario (1 passed)
      1 step (1 passed)

      """
