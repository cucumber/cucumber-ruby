@one
Feature: Sample

    @two @three
  Scenario: Missing
    Given missing

@three
  Scenario: Passing
    Given passing
      |a|b|
      |c|d|
  
  @four
  Scenario: Failing
    Given failing
      """
      hello
      """
