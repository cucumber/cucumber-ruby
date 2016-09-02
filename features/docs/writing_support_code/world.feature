Feature: World

  In order to isolate each test scenario, the steps definitions belonging to the
  same scenario will run in a isolated context, called 'world'. A world also
  contains the helpers methods that will be used in the step definitions.

  It is possible to add helpers methods to a world in three different ways:

  1. Passing a module. In this case its methods will be added directly to the
     world and be usable in the step definitions.

  2. Passing a block, where the return value is the world object.

  3. Passing a hash, where the keys are namespaces and the values are
     modules. In this case, the methods of each module will be accessible using
     the key as prefix.

  Scenario: A world is extended using a module
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

  Scenario: A world is created using a block
    Given a file named "features/support/helpers.rb" with:
      """
      class Helper
        def helper_method
          42
        end
      end

      World do
        Helper.new
      end
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
        Scenario: I call a method from a namespace
          Then the helper method is called
      """
    When I run `cucumber features/f.feature`
    Then it should pass

  Scenario: A world is extended using a module with namespace
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

  Scenario: A world is extended using multiple modules with different namespaces
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
