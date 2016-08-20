Feature: World Namespaces

  In order to better organise the code supporting my tests
  As a cucumber user
  I want to access the method added to a World using an explicit namespace

  Scenario: A single module is imported with namespace
    Given a file named "features/support/helpers.rb" with:
      """
      module Helpers
        def helper_method
          42
        end
      end

      World(my_namespace: Helpers)
      """
    And a file named "features/step_definitions/step.rb" with:
      """
      Then /^the helper method is called$/ do
        expect(my_namespace.helper_method).to eql(42)
      end
      """
    And a file named "features/f.feature" with:
      """
      Feature: Calling a method
        Scenario: I call a method from a namespace
          Then the helper method is called
      """
    When I run `cucumber features/f.feature`
    Then it should pass

  Scenario: Multiple modules are imported with a namespace
    Given a file named "features/support/helpers.rb" with:
      """
      module ModuleOne
        def forty_one
          41
        end
      end

      module ModuleTwo
        def forty_two
          42
        end
      end

      World(module_one: ModuleOne, module_two: ModuleTwo)
      """
    And a file named "features/step_definitions/step.rb" with:
      """
      Then /^the helper method is called$/ do
        expect(module_one.forty_one).to eql(41)
        expect(module_two.forty_two).to eql(42)
      end
      """
    And a file named "features/f.feature" with:
      """
      Feature: Calling a method
        Scenario: I call a method from two namespaces
          Then the helper method is called
      """
    When I run `cucumber features/f.feature`
    Then it should pass

  Scenario: Assigning different modules to the same namespace
    Given a file named "features/support/module_one.rb" with:
      """
      module ModuleOne
        def forty_two
          41
        end

        def module_one_method
          true
        end
      end

      World(namespace: ModuleOne)
      """
    And a file named "features/support/module_two.rb" with:
    """
      module ModuleTwo
        def forty_two
          42
        end

        def module_two_method
          true
        end
      end

      World(namespace: ModuleTwo)
    """
    And a file named "features/step_definitions/step.rb" with:
      """
      Then /^I call a method from module one$/ do
        expect(namespace.module_one_method).to eql(true)
      end

      Then /^I call a method from module two$/ do
        expect(namespace.module_two_method).to eql(true)
      end

      Then /^I call a method defined in both modules$/ do
        expect(namespace.forty_two).to eql(42)
      end
      """
    And a file named "features/f.feature" with:
      """
      Feature: Calling a method
        Scenario: I call a method
          Then I call a method from module one
          And I call a method from module two
          And I call a method defined in both modules
      """
    When I run `cucumber features/f.feature`
    Then it should pass

  Scenario: Assigning the same module to the same namespace in different contexts
    Given a file named "features/support/module_one.rb" with:
      """
      module Helpers
        def module_one_method
          true
        end
      end

      World(namespace: Helpers)
      """
    And a file named "features/support/module_two.rb" with:
    """
      module Helpers
        def module_two_method
          true
        end
      end

      World(namespace: Helpers)
    """
    And a file named "features/step_definitions/step.rb" with:
      """
      Then /^I call a method defined in the first context$/ do
        expect(namespace.module_one_method).to eql(true)
      end

      Then /^I call a method defined in the second context$/ do
        expect(namespace.module_two_method).to eql(true)
      end
      """
    And a file named "features/f.feature" with:
      """
      Feature: Calling a method
        Scenario: I call a method
          Then I call a method from module one
          And I call a method from module two
          And I call a method defined in both modules
      """
    When I run `cucumber features/f.feature`
    Then it should pass

  Scenario: A single module is imported without namespace
    Given a file named "features/support/helpers.rb" with:
      """
      module Helpers
        def helper_method
          42
        end
      end

      World(Helpers)
      """
    And a file named "features/step_definitions/step.rb" with:
      """
      Then /^the helper method is called$/ do
        expect(helper_method).to eql(42)
      end
      """
    And a file named "features/f.feature" with:
      """
      Feature: Calling a method
        Scenario: I call a method without namespaces
          Then the helper method is called
      """
    When I run `cucumber features/f.feature`
    Then it should pass
