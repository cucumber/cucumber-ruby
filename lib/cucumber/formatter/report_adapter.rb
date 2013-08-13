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
        formatter.log :before_test_step
      end

      def after_test_step(test_step, result)
        formatter.log :after_test_step
        test_step.describe_source_to(event_stack, result)
      end

      def after_test_case(test_case, result)
        record_test_case_result(result)
      end

      def after_suite
        event_stack.empty
      end

      private

      def event_stack
        @event_stack ||= EventStack.new(runtime, formatter)
      end

      EventStack = Struct.new(:runtime, :formatter) do
        def hook(*);end

        def feature(feature, *)
          @background = nil
          push FeaturesPrinter.new(formatter)
          push FeaturePrinter.new(formatter, feature)
        end

        def background(background, *)
          @background = background
          push BackgroundPrinter.new(formatter, background)
        end

        def scenario(scenario, *)
          @background = nil
          return if scenario == @scenario
          @scenario = scenario
          pop_to FeaturePrinter
          push ScenarioPrinter.new(formatter, scenario)
        end

        def step(step, result)
          stack.last.step(step, result, runtime, @background)
        end

        def scenario_outline(scenario_outline, *)
          @background = nil
          pop_to FeaturePrinter
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

        def pop_to(printer_type)
          pop until stack.last.class == printer_type
          self
        end

        private

        def current_background
          @background
        end

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
            formatter.before_features(nil)
          end

          def after
            formatter.after_features(nil)
          end
        end

        FeaturePrinter = Struct.new(:formatter, :feature) do
          def before
            formatter.before_feature(feature)
            feature.tags.accept TagPrinter.new(formatter)
            formatter.feature_name(feature.keyword, feature.name)
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
            source_indent = 1 # TODO
            formatter.scenario_name(scenario.keyword, scenario.name, scenario.location.to_s, source_indent)
            self
          end

          def step(step, result, runtime, background)
            @steps_printer ||= StepsPrinter.new(formatter).before
            @steps_printer.step(step, result, runtime, background)
          end

          def after
            @steps_printer.after if @steps_printer
            formatter.after_feature_element(scenario)
            self
          end
        end

        BackgroundPrinter = Struct.new(:formatter, :background) do
          def before
            formatter.before_background(background)
            source_indent = 1 # TODO
            formatter.background_name(background.keyword, background.name, background.location.to_s, source_indent)
            self
          end

          def step(step, result, runtime, background)
            @steps_printer ||= StepsPrinter.new(formatter).before
            @steps_printer.step(step, result, runtime, background)
          end

          def after
            @steps_printer.after if @steps_printer
            formatter.after_background(background)
            self
          end
        end

        StepsPrinter = Struct.new(:formatter) do
          def before
            formatter.before_steps
            self
          end

          def step(step, result, runtime, background)
            StepPrinter.new(formatter, runtime, step, result, background).before.after
          end

          def after
            formatter.after_steps
            self
          end
        end

        StepPrinter = Struct.new(:formatter, :runtime, :step, :result, :background) do
          def before
            formatter.before_step(step)
            self
          end

          def after
            formatter.before_step_result(step_result)
            source_indent = 1 # TODO
            formatter.step_name(step.keyword, step_match(step), step_result.status, source_indent, background, step.location.to_s)
            formatter.after_step_result
            formatter.after_step
            self
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
            formatter.before_tags tags
            tags.tags.each do |tag|
              formatter.visit_tag_name tag.name
            end
            formatter.after_tags tags
          end
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
