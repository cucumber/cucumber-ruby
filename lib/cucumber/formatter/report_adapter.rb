module Cucumber
  module Formatter
    ReportAdapter = Struct.new(:runtime, :formatter) do

      def before_test_case(test_case)
        formatter.before_feature_element(:element)
      end

      def after_test_case(test_case, result)
        record_test_case_result(result)
        formatter.after_feature_element(:element)
      end

      def before_test_step(step)
      end

      def after_test_step(step, result)
        record_step_result(result) do |step_result|
          formatter.before_step_result(step_result)
          step.describe_source_to(source_printer, runtime, step_result)
          formatter.after_step_result(step_result) if formatter.respond_to?(:after_step_result)
        end
      end

      def after_suite
        formatter.after_features(nil)
      end

      private

      def case_result(result)
      end

      def source_printer
        @source_printer ||= SourcePrinter.new(formatter)
      end

      def record_test_case_result(result)
        scenario = LegacyResultBuilder.new(result).scenario
        runtime.record_result(scenario)
        yield scenario if block_given?
      end

      def record_step_result(result)
        step_result = LegacyResultBuilder.new(result).step_result
        runtime.step_visited(step_result)
        yield step_result if block_given?
      end

      SourcePrinter = Struct.new(:formatter) do
        def hook(*)
        end

        def feature(feature, *)
          return if feature == @current_feature
          formatter.before_feature(feature)
          formatter.feature_name(feature.keyword, feature.name)
          @current_feature = feature
        end

        def scenario(scenario, *)
          return if scenario == @current_scenario
          source_indent = 1 # TODO
          formatter.scenario_name(scenario.keyword, scenario.name, scenario.location.to_s, source_indent)
          @current_scenario = scenario
        end

        def background(background, *)
          return if background == @current_background
          source_indent = 1 # TODO
          formatter.background_name(background.keyword, background.name, background.location.to_s, source_indent)
          @current_background = background
        end

        def step(step, runtime, step_result)
          source_indent = 1 # TODO
          formatter.step_name(step.keyword, step_match(runtime, step), step_result.status, source_indent, @current_background, step.location.to_s)
        end

        def scenario_outline(node, *)
          return if node == @current_scenario_outline
          source_indent = 1 # TODO
          formatter.scenario_name(node.keyword, node.name, node.location.to_s, source_indent)
          formatter.before_outline_table(node)
          @current_scenario_outline = node
        end

        def examples_table(node, *)
          return if node == @current_examples_table
          formatter.examples_name(node.keyword, node.name)
          @current_examples_table = node
        end

        def examples_table_row(row, runtime, step_result)
          row.values.each do |value|
            formatter.table_cell_value(value, step_result.status)
          end
        end

        private

        def step_match(runtime, step)
          runtime.step_match(step.name)
        rescue Cucumber::Undefined
          NoStepMatch.new(step, step.name)
        end
      end

      require 'cucumber/ast/step_result'
      class LegacyResultBuilder
        def initialize(result)
          result.describe_to(self)
        end

        def passed
          @status = :passed
        end

        def failed
          @status = :failed
        end

        def undefined
          @status = :undefined
        end

        def skipped
          @status = :skipped
        end

        def exception(exception, *)
          @exception = exception
        end

        def duration(*); end

        def step_result
          Ast::StepResult.new(:keyword, :step_match, :multiline_arg, @status, @exception, :source_indent, :background, :file_colon_line)
        end

        def scenario
          LegacyScenario.new(@status)
        end

        LegacyScenario = Struct.new(:status)
      end

    end
  end
end
