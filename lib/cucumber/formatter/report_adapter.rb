module Cucumber
  module Formatter
    ReportAdapter = Struct.new(:runtime, :formatter) do

      def before_test_case(test_case)
      end

      def after_test_case(test_case, result)
        record_test_case_result(result)
        event_stack.pop
      end

      def before_test_step(test_step)
        test_step.describe_source_to(event_stack)
      end

      def after_test_step(test_step, result)
        record_step_result(result) do |step_result|
          test_step.describe_source_to(event_stack, step_result)
        end
      end

      def after_suite
        event_stack.empty
      end

      private

      def event_stack
        @event_stack ||= EventStack.new(formatter)
      end

      EventStack = Struct.new(:formatter) do
        def hook(*);end

        def feature(feature, *)
          push FeaturesPrinter.new(formatter)
          push FeaturePrinter.new(formatter, feature)
        end

        def scenario(scenario, *)
          push ScenarioPrinter.new(formatter, scenario)
        end

        def step(step, step_result = nil)
          return unless step_result
          push StepsPrinter.new(formatter)
          push StepPrinter.new(formatter, step, step_result)
        end

        def scenario_outline(scenario_outline, *)
          push ScenarioOutlinePrinter.new(formatter, scenario_outline)
        end

        def examples_table(examples_table, *)
          push ExamplesTablePrinter.new(formatter, examples_table)
        end

        def examples_table_row(examples_table_row, *)
          push ExamplesTableRowPrinter.new(formatter, examples_table_row)
        end

        def empty
          pop until stack.empty?
        end

        def pop
          printer = stack.pop
          printer.after
          self
        end

        def inspect
          stack.map { |o| o.class }.inspect
        end

        private

        def push(printer)
          return if stack.include? printer
          stack.push(printer)
          printer.before
        end

        def stack
          @stack ||= []
        end

        FeaturesPrinter = Struct.new(:formatter) do
          def before
            formatter.before_features
          end

          def after
            formatter.after_features
          end
        end

        FeaturePrinter = Struct.new(:formatter, :feature) do
          def before
            formatter.before_feature
            feature.tags.accept TagPrinter.new(formatter)
            formatter.feature_name
            self
          end

          def after
            formatter.after_feature
            self
          end
        end

        ScenarioPrinter = Struct.new(:formatter, :scenario) do
          def before
            formatter.before_feature_element(scenario)
            scenario.tags.accept TagPrinter.new(formatter)
            formatter.scenario_name
            self
          end

          def after
            formatter.after_feature_element
            self
          end
        end

        StepsPrinter = Struct.new(:formatter) do
          def before
            formatter.before_steps
            self
          end

          def after
            formatter.after_steps
            self
          end
        end

        StepPrinter = Struct.new(:formatter, :step, :step_result) do
          def before
            formatter.before_step
            self
          end

          def after
            formatter.before_step_result
            formatter.step_name
            formatter.after_step_result
            formatter.after_step
            self
          end
        end

        ScenarioOutlinePrinter = Struct.new(:formatter, :scenario_outline) do
          def before
            self
          end

          def after
            self
          end
        end

        ExamplesTablePrinter = Struct.new(:formatter, :examples_table) do
          def before
            self
          end

          def after
            self
          end
        end

        ExamplesTableRowPrinter = Struct.new(:formatter, :examples_table) do
          def before
            self
          end

          def after
            self
          end
        end

        TagPrinter = Struct.new(:formatter) do
          def visit_tags(tags)
            formatter.before_tags(tags)
            formatter.after_tags(tags)
          end
        end
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
