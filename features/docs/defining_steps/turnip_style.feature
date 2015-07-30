Feature: Turnip-style Placeholders in Step Definitions

  Instead of using regexps for simple step definitions we can use :placeholders

  Scenario: Use place holders in step definitions
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Given("there is a monster called :name") do |args|
        @monsters ||= []
        @monsters << args.name
      end

      Then("there is/are :count monster(s)") do |args|
        expect(@monsters.count).to eq(args.count.to_i)
      end
      """
    And a file named "features/using_placeholders.feature" with:
      """
      Feature:
        Scenario:
          Given there is a monster called Jonas
          And there is a monster called "Jonas Nicklas"
          Then there are 2 monsters
      """
    When I run `cucumber --strict`
    Then it should pass

  Scenario:
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Given("a step that :state") do |args|
        fail if args.state =~ /fail/
      end
      """
    And a file named "features/using_placeholders.feature" with:
      """
      Feature: Failure mode
        Scenario: failing
          Given a step that fails
      """
    When I run `cucumber --strict`
    Then it should fail with exactly:
      """
      Feature: Failure mode

        Scenario: failing         # features/using_placeholders.feature:2
          Given a step that fails # features/step_definitions/steps.rb:1
             (RuntimeError)
            ./features/step_definitions/steps.rb:2:in `"a step that :state"'
            features/using_placeholders.feature:3:in `Given a step that fails'

      Failing Scenarios:
      cucumber features/using_placeholders.feature:2 # Scenario: failing

      1 scenario (1 failed)
      1 step (1 failed)
      0m0.012s

      """

  @wip
  Scenario: Define custom placeholders
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Placeholder(:count) do
        match(/\d+/) do |count|
          count.to_i
        end
      end

      Given("there are :count monsters") do |args|
        args.count.times do
          # yes this is a number
        end
      end
      """
    And a file named "features/using_placeholders.feature" with:
      """
      Feature:
        Scenario:
          Given there are 3 monsters
      """
    When I run `cucumber --strict`
    Then it should pass
