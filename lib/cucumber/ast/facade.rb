require 'cucumber/runtime'
require 'cucumber'
require 'cucumber/multiline_argument'
require 'cucumber/core/test/result'

module Cucumber
  # Decorates the `Cucumber::Core::Test::Case` to look like the 
  # Cucumber 1.3's `Cucumber::Ast::Scenario`.
  #
  # This is for backwards compatability in before / after hooks.
  module Ast
    class Facade
      def initialize(test_case)
        @test_case = test_case
        @row = nil
        test_case.describe_source_to(self)
      end

      def feature(feature)
        @feature = feature
      end

      def scenario(scenario)
        @factory = Scenario
      end

      def scenario_outline(scenario)
        @factory = ScenarioOutlineExample
      end

      def examples_table(examples_table)
      end

      def examples_table_row(row)
        @row = row
      end

      def build_scenario
        if @factory == Scenario
          @factory.new(@test_case, Feature.new(@feature.legacy_conflated_name_and_description))
        else
          @factory.new(@test_case, Feature.new(@feature.legacy_conflated_name_and_description), @row)
        end
      end

      class Scenario
        def initialize(test_case, feature, result = Core::Test::Result::Unknown.new)
          @test_case = test_case
          @feature = feature
          @result = result
        end

        def accept_hook?(hook)
          hook.tag_expressions.all? { |expression| @test_case.match_tags?(expression) }
        end

        def failed?
          @result.failed?
        end

        def passed?
          !failed?
        end

        def language
          @test_case.language
        end

        def feature
          @feature
        end

        def name
          "#{@test_case.name}"
        end

        def title
          warn("deprecated: call #name instead")
          name
        end

        def source_tags
          #warn('deprecated: call #tags instead')
          tags
        end

        def source_tag_names
          tags.map &:name
        end

        def skip_invoke!
          Cucumber.deprecate(self.class.name, __method__, "Call #skip_this_scenario on the World directly")
          raise Cucumber::Core::Test::Result::Skipped
        end

        def tags
          @test_case.tags
        end

        def outline?
          false
        end

        def with_result(result)
          self.class.new(@test_case, @feature, result)
        end
      end

      class ScenarioOutlineExample < Scenario
        def initialize(test_case, feature, row, result = Core::Test::Result::Unknown.new)
          super(test_case, feature, result)
          @row = row
        end

        def outline?
          true
        end

        def scenario_outline
          self.class.new(@test_case, @feature, nil, @result)
        end

        def with_result(result)
          self.class.new(@test_case, @feature, @row, result)
        end

        def name
          @name ||= build_name
        end

        private
        
        def build_name
          if @row
            '| ' + @row.values.join(' | ') + ' |'
          else
            NameBuilder.new(@test_case).result
          end
        end

        class NameBuilder
          attr_reader :result

          def initialize(test_case)
            test_case.describe_source_to self
          end

          def feature(*)
            self
          end

          def scenario(*)
            self
          end

          def scenario_outline(outline)
            @result = outline.name
            self
          end

          def examples_table(*)
            self
          end

          def examples_table_row(*)
            self
          end
        end
      end

      Feature = Struct.new(:name)

    end
  end
end
