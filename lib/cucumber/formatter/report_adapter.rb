module Cucumber
  module Formatter

    FormatterWrapper = Struct.new(:formatter) do
      def method_missing(message, *args)
        formatter.send(message, *args) if formatter.respond_to?(message)
      end
    end

    ReportAdapter = Struct.new(:runtime, :formatter) do
      def initialize(runtime, formatter)
        super runtime, FormatterWrapper.new(formatter)
      end

      def before_test_case(test_case)
      end

      def before_test_step(test_step)
      end

      def after_test_step(test_step, result)
        test_step.describe_source_to(printer, result)
      end

      def after_test_case(test_case, result)
        record_test_case_result(result)
      end

      def after_suite
        printer.after
      end

      private

      def printer
        @printer ||= FeaturesPrinter.new(formatter, runtime).before
      end

      # Provides a DSL for making the printers themselves more terse
      class Printer < Struct
        def self.before(&block)
          define_method(:before) do
            instance_eval(&block)
            self
          end
        end

        def self.after(&block)
          define_method(:after) do
            @child.after if @child
            instance_eval(&block)
            self
          end
        end

        def open(printer_type, node)
          args = [formatter, runtime, node]
          @child.after if @child
          @child = printer_type.new(*args).before
        end

        def method_missing(message, *args)
          raise "#{self.class} has no @child set" unless @child
          return super unless @child.respond_to?(message)
          @child.send(message, *args)
        end

        def respond_to_missing?(message, include_private = false)
          @child.respond_to?(message, include_private) || super
        end

        def for_new(node, &block)
          @current_nodes ||= {}
          if @current_nodes[node.class] != node
            @current_nodes[node.class] = node
            block.call
          end
        end
      end

      FeaturesPrinter = Printer.new(:formatter, :runtime) do
        before do
          formatter.before_features(nil)
        end

        def hook(*); end

        def feature(feature, *)
          for_new(feature) do
            open FeaturePrinter, feature
          end
        end

        after do
          formatter.after_features(nil)
        end
      end

      FeaturePrinter = Printer.new(:formatter, :runtime, :feature) do
        before do
          formatter.before_feature(feature)
          feature.tags.accept TagPrinter.new(formatter)
          formatter.feature_name(feature.keyword, feature.name)
        end

        def background(background, *)
          open BackgroundPrinter, background
        end

        def scenario(scenario, *)
          for_new(scenario) do
            open ScenarioPrinter, scenario
          end
        end

        def scenario_outline(scenario_outline, *)
          for_new(scenario_outline) do
            open ScenarioOutlinePrinter, scenario_outline
          end
        end

        after do
          formatter.after_feature
        end
      end

      ScenarioPrinter = Printer.new(:formatter, :runtime, :scenario) do
        before do
          formatter.before_feature_element(scenario)
          scenario.tags.accept TagPrinter.new(formatter)
          source_indent = 1 # TODO
          formatter.scenario_name(scenario.keyword, scenario.name, scenario.location.to_s, source_indent)
        end

        def step(step, result)
          @child ||= StepsPrinter.new(formatter).before
          super step, result, runtime, background = nil
        end

        after do
          formatter.after_feature_element(scenario)
        end
      end

      BackgroundPrinter = Printer.new(:formatter, :runtime, :background) do
        before do
          formatter.before_background(background)
          source_indent = 1 # TODO
          formatter.background_name(background.keyword, background.name, background.location.to_s, source_indent)
        end

        def step(step, result)
          @child ||= StepsPrinter.new(formatter).before
          super step, result, runtime, background
        end

        after do
          formatter.after_background(background)
        end
      end

      StepsPrinter = Printer.new(:formatter) do
        before do
          formatter.before_steps
        end

        def step(step, result, runtime, background)
          StepPrinter.new(formatter, runtime, step, result, background).before.after
        end

        after do
          formatter.after_steps
        end
      end

      StepPrinter = Printer.new(:formatter, :runtime, :step, :result, :background) do
        before do
          formatter.before_step(step)
        end

        after do
          formatter.before_step_result(step_result)
          source_indent = 1 # TODO
          formatter.step_name(step.keyword, step_match(step), step_result.status, source_indent, background, step.location.to_s)
          if step.multiline_arg
            formatter.before_multiline_arg(step.multiline_arg)
            step.multiline_arg.describe_to(formatter)
            formatter.after_multiline_arg(step.multiline_arg)
          end
          formatter.after_step_result
          formatter.after_step
        end

        private

        def step_match(step)
          runtime.step_match(step.name)
        rescue Cucumber::Undefined
          NoStepMatch.new(step, step.name)
        end

        def step_result
          return @step_result if @step_result
          step_result = LegacyResultBuilder.new(result).step_result(background)
          runtime.step_visited step_result
          @step_result = step_result
        end

      end

      ScenarioOutlinePrinter = Printer.new(:formatter, :runtime, :node) do
        before do
          formatter.before_feature_element(node)
          node.tags.accept TagPrinter.new(formatter)
          source_indent = 1 # TODO
          formatter.scenario_name(node.keyword, node.name, node.location.to_s, source_indent)
          outline_steps_printer = OutlineStepsPrinter.new(formatter, runtime)
          node.describe_to outline_steps_printer
          outline_steps_printer.after
        end

        def examples_table(examples_table, *)
          @child ||= ExamplesArrayPrinter.new(formatter, runtime).before
          @child.examples_table(examples_table)
        end

        after do
          formatter.after_feature_element(node)
        end
      end

      OutlineStepsPrinter = Struct.new(:formatter, :runtime) do
        def scenario_outline(node, &descend)
          descend.call # print the outline steps
        end

        def outline_step(step)
          result = Core::Test::Result::Skipped.new
          steps_printer.step step, result, runtime, background = nil
        end

        def examples_table(*);end

        def after
          steps_printer.after
        end

        private

        def steps_printer
          @steps_printer ||= StepsPrinter.new(formatter).before
        end
      end

      ExamplesArrayPrinter = Printer.new(:formatter, :runtime) do
        before do
          formatter.before_examples_array
        end

        def examples_table(examples_table)
          for_new(examples_table) do
            open ExamplesTablePrinter, examples_table
          end
        end

        after do
          formatter.after_examples_array
        end
      end

      ExamplesTablePrinter = Printer.new(:formatter, :runtime, :node) do
        before do
          formatter.before_examples(node)
          formatter.examples_name
          formatter.before_outline_table
          ExamplesTableRowPrinter.new(formatter, runtime, node.header).before.after
        end

        def examples_table_row(examples_table_row, *)
          for_new(examples_table_row) do
            open ExamplesTableRowPrinter, examples_table_row
          end
        end

        after do
          formatter.after_outline_table
          formatter.after_examples(node)
        end
      end

      ExamplesTableRowPrinter = Printer.new(:formatter, :runtime, :node) do
        before do
          formatter.before_table_row
        end

        def step(step, *)
        end

        after do
          node.values.each do |value|
            formatter.before_table_cell
            formatter.table_cell_value
            formatter.after_table_cell
          end
          formatter.after_table_row
        end
      end

      TagPrinter = Struct.new(:formatter) do
        def visit_tags(tags)
          formatter.before_tags tags
          tags.tags.each do |tag|
            formatter.visit_tag_name tag.name
          end
          formatter.after_tags tags
        end
      end

      def record_test_case_result(result)
        scenario = LegacyResultBuilder.new(result).scenario
        runtime.record_result(scenario)
        yield scenario if block_given?
      end

      SourcePrinter = Struct.new(:formatter) do
        def hook(*)
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

        def step_result(background)
          Ast::StepResult.new(:keyword, :step_match, :multiline_arg, @status, @exception, :source_indent, background, :file_colon_line)
        end

        def scenario
          LegacyScenario.new(@status)
        end

        LegacyScenario = Struct.new(:status)
      end

    end
  end
end
