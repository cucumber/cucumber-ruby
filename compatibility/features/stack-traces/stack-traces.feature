Feature: Stack traces
  Stack traces can help you diagnose the source of a bug.
  Cucumber provides helpful stack traces that includes the stack frames from the
  Gherkin document and remove uninteresting frames by default

  The first line of the stack trace will contain a reference to the feature file.

  Scenario: A failing step
    When a step throws an exception
