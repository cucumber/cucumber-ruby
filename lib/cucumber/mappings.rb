require 'cucumber/runtime'
require 'cucumber'

module Cucumber
    class Mappings

      def initialize(runtime = nil)
        @runtime = runtime
      end

      def test_step(step, mapper)
        step_match = runtime.step_match(step.name)
        mapper.map { step_match.invoke(step.multiline_arg) }
      rescue Cucumber::Undefined
      end

      def test_case(test_case, mapper)
        scenario = Scenario.new(test_case)
        mapper.before do
          ruby.begin_rb_scenario(scenario)
        end
        ruby.hooks_for(:before, scenario).each do |hook|
          mapper.before do
            hook.invoke('Before', scenario)
          end
        end
        ruby.hooks_for(:after, scenario).each do |hook|
          mapper.after do
            hook.invoke('After', scenario)
          end
        end
        ruby.hooks_for(:around, scenario).each do |hook|
          mapper.around do |run_scenario|
            hook.invoke('Around', scenario, &run_scenario)
          end
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
      class Scenario
        def initialize(test_case)
          @test_case = test_case
        end

        def accept_hook?(hook)
          hook.tag_expressions.all? { |expression| @test_case.match_tags?(expression) }
        end

        def language
          @test_case.language
        end
      end
    end
end
