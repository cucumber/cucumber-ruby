@spawn
Feature: Reformat files with --autoformat

  The `--autoformat DIRECTORY` flag reformats (or pretty prints)
  feature files and write them to DIRECTORY. Be careful if you choose
  to overwrite the originals.

  This command implies `--dry-run --format pretty`.

  Scenario:
    Given a file named "features/test.feature" with:
      """
      # Feature comment
            @one
      Feature: Sample

          @two @three
      Scenario: Missing
          Given missing

      # Scenario comment
      @three
        Scenario: Passing
          Given passing
            |a|b|
            |c|d|

        @four
        Scenario: Failing
          Given failing
            \"\"\"
            hello
            \"\"\"
      """
    When I run `cucumber --autoformat tmp/formatted features/test.feature`
    Then the stderr should not contain anything
    Then the file "tmp/formatted/features/test.feature" should contain:
      """
      # Feature comment
      @one
      Feature: Sample

        @two @three
        Scenario: Missing
          Given missing

        # Scenario comment
        @three
        Scenario: Passing
          Given passing
            | a | b |
            | c | d |

        @four
        Scenario: Failing
          Given failing
            \"\"\"
            hello
            \"\"\"
      """
