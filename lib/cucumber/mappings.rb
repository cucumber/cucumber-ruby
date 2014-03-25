require 'cucumber/runtime'
require 'cucumber'
require 'cucumber/multiline_argument'

module Cucumber
  class Mappings

    def initialize(runtime = nil)
      @runtime = runtime
    end

    def test_step(step, mapper)
      step_match = runtime.step_match(step.name)
      multiline_arg = MultilineArgument.from(step.multiline_arg)
      mapper.map { step_match.invoke(multiline_arg) }
    rescue Cucumber::Undefined
    end

    def test_case(test_case, mapper)
      scenario = Source.new(test_case).build_scenario
      mapper.before do
        ruby.begin_rb_scenario(scenario)
      end
      ruby.hooks_for(:before, scenario).each do |hook|
        mapper.before(&hook.build_invoker('Before', scenario))
      end
      ruby.hooks_for(:after, scenario).each do |hook|
        mapper.after(&hook.build_invoker('After', scenario))
      end
      ruby.hooks_for(:around, scenario).each do |hook|
        mapper.around(&hook.build_invoker('Around', scenario, &run_scenario))
      end
    end

    def runtime
      return @runtime if @runtime
      result = Cucumber::Runtime.new
      result.support_code.load_files!(support_files)
      @runtime = result
    end

    private

    def ruby
      @ruby ||= runtime.load_programming_language('rb')
    end

    def support_files
      Dir['features/**/*.rb']
    end

    # adapts our test_case to look like the Cucumber Runtime's Scenario
    class TestCase
      def initialize(test_case, feature)
        @test_case = test_case
        @feature = feature
      end

      def accept_hook?(hook)
        hook.tag_expressions.all? { |expression| @test_case.match_tags?(expression) }
      end

      def language
        @test_case.language
      end

      def feature
        @feature
      end

      def name
        @test_case.name
      end
    end

    class Scenario < TestCase
    end

    class ScenarioOutlineExample < TestCase
      def scenario_outline
        self
      end
    end

    class Source
      def initialize(test_case)
        @test_case = test_case
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
      end

      def build_scenario
        @factory.new(@test_case, Feature.new(@feature.name))
      end
    end

    Feature = Struct.new(:name)
  end
end
