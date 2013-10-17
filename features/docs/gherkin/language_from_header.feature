@wip-new-core
Feature: Choosing the language from the feature file header

  In order to simplify command line and settings in IDEs, Cucumber picks
  up the parser language from a `# language` comment at the beginning of
  any feature file. See the examples below for the exact syntax.

  Scenario: LOLCAT
    Given a file named "features/lolcat.feature" with:
      """
      # language: en-lol
      OH HAI: STUFFING
        B4: HUNGRY
        MISHUN: CUKES
          DEN KTHXBAI
      """
    When I run `cucumber -i features/lolcat.feature`
    Then it should pass with:
      """
      # language: en-lol
      OH HAI: STUFFING

        B4: HUNGRY # features/lolcat.feature:3

        MISHUN: CUKES # features/lolcat.feature:4
          DEN KTHXBAI # features/lolcat.feature:5

      1 scenario (1 undefined)
      1 step (1 undefined)

      """
