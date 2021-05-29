Feature: Around hooks

  In order to support transactional scenarios for database libraries
  that provide only a block syntax for transactions, Cucumber should
  permit definition of Around hooks.

  Background:
    Given a file named "features/support/env.rb" with:
      """
      module HookLoggerWorld
        def logged_hooks
          @logged_hooks ||= []
        end

        def log_hook(name)
          logged_hooks << name
        end
      end

      World(HookLoggerWorld)
      """

  Scenario: A single Around hook
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Then /^the hook is called$/ do
        expect(logged_hooks).to eq(['Around'])
      end
      """
    And a file named "features/support/hooks.rb" with:
      """
      Around do |scenario, block|
        log_hook('Around')
        block.call
      end
      """
    And a file named "features/f.feature" with:
      """
      Feature: Around hooks
        Scenario: using hook
          Then the hook is called
      """
    When I run `cucumber features/f.feature`
    Then it should pass with:
      """
      Feature: Around hooks

        Scenario: using hook      # features/f.feature:2
          Then the hook is called # features/step_definitions/steps.rb:1

      1 scenario (1 passed)
      1 step (1 passed)

      """

  Scenario: Multiple Around hooks
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Then /^the hooks are called in the correct order$/ do
        expect(logged_hooks).to eq(['A', 'B', 'C'])
      end
      """
    And a file named "features/support/hooks.rb" with:
      """
      Around do |scenario, block|
        log_hook('A')
        block.call
      end

      Around do |scenario, block|
        log_hook('B')
        block.call
      end

      Around do |scenario, block|
        log_hook('C')
        block.call
      end
      """
    And a file named "features/f.feature" with:
      """
      Feature: Around hooks
        Scenario: using multiple hooks
          Then the hooks are called in the correct order
      """
    When I run `cucumber features/f.feature`
    Then it should pass with:
      """
      Feature: Around hooks

        Scenario: using multiple hooks                   # features/f.feature:2
          Then the hooks are called in the correct order # features/step_definitions/steps.rb:1

      1 scenario (1 passed)
      1 step (1 passed)

      """

  Scenario: Mixing Around, Before, and After hooks
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Then /^the Around hook is called around Before and After hooks$/ do
        expect(logged_hooks).to eq(['Around', 'Before'])
      end
      """
    And a file named "features/support/hooks.rb" with:
      """
      Around do |scenario, block|
        log_hook 'Around'
        block.call
        log_hook 'Around'
        expect(logged_hooks).to eq(['Around', 'Before', 'After', 'Around'])
      end

      Before do |scenario|
        log_hook 'Before'
      end

      After do |scenario|
        log_hook 'After'
        expect(logged_hooks).to eq(['Around', 'Before', 'After'])
      end
      """
    And a file named "features/f.feature" with:
      """
      Feature: Around hooks
        Scenario: Mixing Around, Before, and After hooks
          Then the Around hook is called around Before and After hooks
      """
    When I run `cucumber features/f.feature`
    Then it should pass with:
      """
      Feature: Around hooks

        Scenario: Mixing Around, Before, and After hooks               # features/f.feature:2
          Then the Around hook is called around Before and After hooks # features/step_definitions/steps.rb:1

      1 scenario (1 passed)
      1 step (1 passed)

      """

  Scenario: Around hooks with tags
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Then /^the Around hooks with matching tags are called$/ do
        expect(logged_hooks).to eq(['one', 'one or two'])
      end
      """
    And a file named "features/support/hooks.rb" with:
      """
      Around('@one') do |scenario, block|
        log_hook('one')
        block.call
      end

      Around('@one or @two') do |scenario, block|
        log_hook('one or two')
        block.call
      end

      Around('@one and @two') do |scenario, block|
        log_hook('one and two')
        block.call
      end

      Around('@two') do |scenario, block|
        log_hook('two')
        block.call
      end
      """
    And a file named "features/f.feature" with:
      """
      Feature: Around hooks
      @one
        Scenario: Around hooks with tags
          Then the Around hooks with matching tags are called
      """
    When I run `cucumber -q -t @one features/f.feature`
    Then it should pass with:
      """
      Feature: Around hooks

      @one
        Scenario: Around hooks with tags
          Then the Around hooks with matching tags are called

      1 scenario (1 passed)
      1 step (1 passed)

      """

  Scenario: Around hooks with scenario outlines
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Then /^the hook is called$/ do
        expect(logged_hooks).to eq(['Around'])
      end
      """
    And a file named "features/support/hooks.rb" with:
      """
      Around do |scenario, block|
        log_hook('Around')
        block.call
      end
      """
    And a file named "features/f.feature" with:
      """
      Feature: Around hooks with scenario outlines
        Scenario Outline: using hook
          Then the hook is called

          Examples:
            | Number |
            | one    |
            | two    |
      """
    When I run `cucumber features/f.feature`
    Then it should pass with:
      """
      Feature: Around hooks with scenario outlines

        Scenario Outline: using hook # features/f.feature:2
          Then the hook is called    # features/f.feature:3

          Examples:
            | Number |
            | one    |
            | two    |

      2 scenarios (2 passed)
      2 steps (2 passed)

      """

  Scenario: Around Hooks and the Custom World
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Then /^the world should be available in the hook$/ do
        $previous_world = self
        expect($hook_world).to eq(self)
      end

      Then /^what$/ do
        expect($hook_world).not_to eq($previous_world)
      end
      """
    And a file named "features/support/hooks.rb" with:
      """
      Around do |scenario, block|
        $hook_world = self
        block.call
      end
      """
    And a file named "features/f.feature" with:
      """
      Feature: Around hooks
        Scenario: using hook
          Then the world should be available in the hook

        Scenario: using the same hook
          Then what
      """
    When I run `cucumber features/f.feature`
    Then it should pass
