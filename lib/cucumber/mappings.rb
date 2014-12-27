require 'cucumber/runtime'
require 'cucumber'
require 'cucumber/multiline_argument'

module Cucumber
  class Mappings

    def self.for(runtime)
      if runtime.dry_run?
        Mappings::DryRun.new(runtime)
      else
        Mappings.new(runtime)
      end
    end

    def initialize(runtime = nil)
      @runtime = runtime
    end

    def test_step(step, mapper)
      map_step(step, mapper)
      map_after_step_hooks(mapper)
    end

    def test_case(test_case, mapper)
      map_test_case(test_case, mapper)
      map_test_case_hooks(mapper)
    end

    def runtime
      return @runtime if @runtime
      result = Cucumber::Runtime.new
      result.support_code.load_files!(support_files)
      @runtime = result
    end

    private

    attr_reader :scenario
    private :scenario

    def ruby
      @ruby ||= runtime.load_programming_language('rb')
    end

    def support_files
      Dir['features/**/*.rb']
    end

    def map_step(step, mapper)
      step.describe_source_to MapStep.new(runtime, mapper)
    end

    def map_after_step_hooks(mapper)
      ruby.hooks_for(:after_step, scenario).each do |hook|
        mapper.after do
          hook.invoke 'AfterStep', scenario
        end
      end
    end

    def map_test_case(test_case, mapper)
      @scenario = Source.new(test_case).build_scenario
      mapper.before do
        runtime.begin_scenario(scenario)
      end
    end

    def map_test_case_hooks(mapper)
      ruby.hooks_for(:before, scenario).each do |hook|
        mapper.before do |result|
          hook.invoke('Before', scenario.with_result(result))
        end
      end
      ruby.hooks_for(:after, scenario).each do |hook|
        mapper.after do |result|
          hook.invoke('After', scenario.with_result(result))
        end
      end
      ruby.hooks_for(:around, scenario).each do |hook|
        mapper.around do |run_scenario|
          hook.invoke('Around', scenario, &run_scenario)
        end
      end
    end

    require 'cucumber/core/test/result'
    # Decorates the `Cucumber::Core::Test::Case` to look like the 
    # Cucumber 1.3's `Cucumber::Ast::Scenario`.
    #
    # This is for backwards compatability in before / after hooks.
    class TestCase
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

      def language
        @test_case.language
      end

      def feature
        @feature
      end

      def name
        @test_case.name
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

    class ScenarioOutlineExample < TestCase
      def outline?
        true
      end

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
        @factory = TestCase
      end

      def scenario_outline(scenario)
        @factory = ScenarioOutlineExample
      end

      def examples_table(examples_table)
      end

      def examples_table_row(row)
      end

      def build_scenario
        @factory.new(@test_case, Feature.new(@feature.legacy_conflated_name_and_description))
      end
    end

    class DryRun < Mappings

      private

      def map_test_case(*)
        # NOOP - we don't want to create World etc for dry run
      end

      def map_step(step, mapper)
        step.describe_source_to MapStep::DryRun.new(runtime, mapper)
      end

      def map_after_step_hooks(mapper)
        # NOOP - we don't need after step hooks for dry run
      end

      def map_test_case_hooks(mapper)
        # NOOP - we don't need hooks for dry run
      end
    end

    Feature = Struct.new(:name)

    class MapStep
      attr_reader :runtime, :mapper
      def initialize(runtime, mapper)
        @runtime = runtime
        @mapper  = mapper
      end

      def step(node)
        step_match = runtime.step_match(node.name)
        map_step(node, step_match)
      rescue Cucumber::Undefined
      end

      def feature(*);end
      def scenario(*);end
      def background(*);end
      def scenario_outline(*);end
      def examples_table(*);end
      def examples_table_row(*);end

      private
      def map_step(node, step_match)
        multiline_arg = MultilineArgument.from_core(node.multiline_arg)
        mapper.map { step_match.invoke(multiline_arg) }
      end

      class DryRun < MapStep
        private
        def map_step(node, step_match)
          mapper.map { raise Core::Test::Result::Skipped, "dry run" }
        end
      end
    end

  end
end
