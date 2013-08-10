module Cucumber
  module Formatter
    ReportAdapter = Struct.new(:runtime, :formatter) do

      def before_test_case(test_case)
        test_case.describe_source_to(before)
      end

      def after_test_case(test_case, result)
        record_test_case_result(result)
        test_case.describe_source_to(after)
      end

      def before_test_step(test_step)
        test_step.describe_source_to(before)
      end

      def after_test_step(test_step, result)
        record_step_result(result) do |step_result|
          test_step.describe_source_to(after, step_result)
        end
      end

      def after_suite
        after.after_suite
      end

      private

      def before
        @before ||= BeforeEvents.new(formatter)
      end

      def after
        @after ||= AfterEvents.new(formatter)
      end

      class BeforeEvents < Struct.new(:formatter)
        def hook
        end

        def feature(feature)
          unless @started
            formatter.before_features
            @started = true
          end
          return if feature == @current_feature
          formatter.after_feature if @current_feature
          formatter.before_feature
          feature.tags.accept(self)
          formatter.feature_name
          @current_feature = feature
        end

        def scenario(scenario)
          return if scenario == @current_scenario
          formatter.before_feature_element(scenario)
          scenario.tags.accept(self)
          formatter.scenario_name
          @current_scenario = scenario
          @steps_started = false
        end

        def scenario_outline(scenario_outline)
          return if scenario_outline == @current_scenario_outline
          outline_printer = OutlinePrinter.new(formatter)
          scenario_outline.describe_to(outline_printer)
          @current_scenario_outline = scenario_outline
        end

        def examples_table(examples_table)
          return if examples_table == @current_examples_table
          formatter.before_examples_table(examples_table)
          examples_table.tags.accept(self)
          @current_examples_table = examples_table
        end

        def examples_table_row(examples_table_row)
        end

        def step(step)
          unless @steps_started
            formatter.before_steps 
            @steps_started = true
          end
          formatter.before_step
        end

        def visit_tags(tags)
          formatter.before_tags(tags)
          formatter.after_tags(tags)
        end
      end

      class OutlinePrinter < Struct.new(:formatter)
        def scenario_outline(scenario_outline, &descend)
          formatter.before_feature_element(scenario_outline)
          scenario_outline.tags.accept(self)
          formatter.scenario_name
          formatter.before_steps
          descend.call
          formatter.after_steps
        end

        def outline_step(step)
          formatter.before_step
          formatter.before_step_result
          formatter.step_name
          formatter.after_step_result
          formatter.after_step
        end

        def examples_table(table)
        end

        def visit_tags(tags)
          formatter.before_tags(tags)
          formatter.after_tags(tags)
        end
      end

      class AfterEvents < Struct.new(:formatter)
        def hook(*)
        end

        def after_suite
          source_printer.after_suite
        end

        def feature(feature, *)
          if @current_feature && (@current_feature != feature)
            formatter.after_feature
          end
          @current_feature = feature
        end

        def scenario(scenario, *)
          after_scenario
          @current_scenario = scenario
        end

        def scenario_outline(scenario_outline, *)
        end

        def examples_table(examples_table, *)
        end

        def examples_table_row(examples_table_row, *)
        end

        def step(step, *)
          formatter.before_step_result
          formatter.step_name
          formatter.after_step_result
          formatter.after_step
        end

        def after_suite
          after_scenario
          formatter.after_feature
          formatter.after_features
        end

        private

        def after_scenario
          if @current_scenario
            formatter.after_steps
            formatter.after_feature_element(:element)
          end
        end
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
