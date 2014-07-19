require 'forwardable'
require 'delegate'
require 'cucumber/errors'

module Cucumber
  module Reports

    class DebugWrapper
      def initialize(receiver)
        @receiver = receiver
      end

      def method_missing(message, *args)
        #p [@receiver.class, message] if ENV['DEBUG']
        @receiver.send(message, *args)
      end
    end

    module Debug
      def debug(*args)
        return unless ENV['DEBUG']
        p args.unshift(self.class).flatten
      end

      module Off
        def debug(*args)
        end
      end
    end

    class FormatterWrapper < BasicObject
      attr_reader :formatters
      private :formatters

      def initialize(formatters)
        @formatters = formatters
      end

      def node(node_name, node, &block)
        method_missing "before_#{node_name}", node
        block.call
        method_missing "after_#{node_name}", node
      end

      def method_missing(message, *args)
        formatters.each do |formatter|
          formatter.send(message, *args) if formatter.respond_to?(message)
        end
      end

      def respond_to_missing?(name, include_private = false)
        formatters.any? { |formatter| formatter.respond_to?(name, include_private) }
      end

    end

    LegacyFormatter = Struct.new(:runtime, :formatter) do
      include Debug::Off

      def initialize(runtime, formatters)
        super runtime, FormatterWrapper.new(formatters)
      end

      extend Forwardable

      def_delegators :formatter,
        :embed,
        :ask,
        :puts

      def before_test_case(test_case)
        printer.before_test_case(test_case)
      end

      def before_test_step(test_step)
        printer.before_test_step(test_step)
      end

      def after_test_step(test_step, result)
        printer.after_test_step(test_step, result)
      end

      def after_test_case(test_case, result)
        record_test_case_result(test_case, result)
        printer.after_test_case(test_case, result)
      end

      def done
        printer.after
      end

      private

      def printer
        @printer ||= DebugWrapper.new(FeaturesPrinter.new(formatter, runtime).before)
      end

      def record_test_case_result(test_case, result)
        scenario = LegacyResultBuilder.new(result).scenario(test_case.name, test_case.location)
        runtime.record_result(scenario)
      end

      require 'cucumber/core/test/timer'
      FeaturesPrinter = Struct.new(:formatter, :runtime) do
        extend Forwardable

        def before
          timer.start
          formatter.before_features(nil)
          self
        end

        def before_test_case(test_case)
          test_case.describe_source_to(self)
          @child.before_test_case(test_case)
        end

        def before_test_step(*args)
          @child.before_test_step(*args)
        end

        def after_test_step(test_step, result)
          @child.after_test_step(test_step, result)
        end

        def after_test_case(*args)
          @child.after_test_case(*args)
        end

        def feature(node, *)
          if node != @current_feature
            @child.after if @child
            @child = DebugWrapper.new(FeaturePrinter.new(formatter, runtime, node).before)
            @current_feature = node
          end
        end

        def scenario(node, *)
        end

        def scenario_outline(node, *)
        end

        def examples_table(node, *)
        end

        def examples_table_row(node, *)
        end

        def after
          @child.after if @child
          formatter.after_features Legacy::Ast::Features.new(timer.sec)
          self
        end

        private

        def timer
          @timer ||= Cucumber::Core::Test::Timer.new
        end
      end

      module TestStepPrinter
        def self.for(test_step, result)
          collector = Collector.new
          test_step.describe_source_to collector, result
          collector.result.freeze
        end

        class Collector
          attr_reader :result

          def initialize
            @result = OpenStruct.new
          end

          def method_missing(name, node, step_result, *args)
            result.send "#{name}=", node
            result.send "#{name}_result=", LegacyResultBuilder.new(step_result)
          end
        end
      end

      FeaturePrinter = Struct.new(:formatter, :runtime, :node) do
        include Debug

        def before
          formatter.before_feature(node)
          Legacy::Ast::Comments.new(node.comments).accept(formatter)
          Legacy::Ast::Tags.new(node.tags).accept(formatter)
          formatter.feature_name node.keyword, indented(node.name) # TODO: change the core's new AST to return name and description separately instead of this lumped-together field
          self
        end

        attr_reader :current_test_step_source

        def before_test_case(test_case)
        end

        def before_test_step(test_step)
        end

        def after_test_step(test_step, result)
          @current_test_step_source = TestStepPrinter.for(test_step, result)
          test_step.describe_source_to(self, result)
          print_step
        end

        def after_test_case(*args)
          if current_test_step_source.step_result.nil?
            print_step_container
          end
          @child.after_test_case
          @previous_test_case_background = @current_test_case_background
        end

        def before_hook(location, result)
          @before_hook_result = LegacyResultBuilder.new(result)
        end

        def after_hook(location, result)
          @child.after_hook LegacyResultBuilder.new(result)
        end

        def after_step_hook(hook, result)
          line = StepBacktraceLine.new(current_test_step_source.step)
          @child.after_step_hook LegacyResultBuilder.new(result).
            append_to_exception_backtrace(line)
        end

        def step(node, result)
        end

        def background(node, *)
          @current_test_case_background = node
        end

        def scenario(node, *)
        end

        def scenario_outline(node, *)
        end

        def examples_table(node, *)
        end

        def examples_table_row(node, *)
        end

        def feature(feature, *args)
        end

        def after
          @child.after
          formatter.after_feature(node)
          self
        end

        private

        def print_step_container
          if current_test_step_source.background

            if same_background_as_previous_test_case?
              set_child_calling_before HiddenBackgroundPrinter.new(formatter, runtime, current_test_step_source.background)
            else
              set_child_calling_before BackgroundPrinter.new(formatter, runtime, current_test_step_source.background)
            end

          elsif current_test_step_source.scenario

            set_child_calling_before ScenarioPrinter.new(formatter, runtime, current_test_step_source.scenario, @before_hook_result)

          elsif current_test_step_source.examples_table_row
            if current_test_step_source.examples_table
              if current_test_step_source.scenario_outline
                set_child_calling_before ScenarioOutlinePrinter.new(formatter, runtime, current_test_step_source.scenario_outline)
              end
              @child.examples_table(current_test_step_source.examples_table)
            end
            @child.examples_table_row(current_test_step_source.examples_table_row, @before_hook_result)
          else
            return
          end
        end

        def same_background_as_previous_test_case?
          current_test_step_source.background == @previous_test_case_background
        end

        def print_step
          return unless current_test_step_source.step_result
          print_step_container
          @child.step(current_test_step_source.step, current_test_step_source.step_result)
        end

        def set_child_calling_before(child)
          if @child
            if @child.node == child.node
              return
            else
            end
          end
          @child.after if @child
          @child = child.before
        end

        def indented(nasty_old_conflation_of_name_and_description)
          indent = ""
          nasty_old_conflation_of_name_and_description.split("\n").map do |l|
            s = "#{indent}#{l}"
            indent = "  "
            s
          end.join("\n")
        end
      end

      BackgroundPrinter = Struct.new(:formatter, :runtime, :node) do

        def before
          formatter.before_background node
          formatter.background_name node.keyword, node.name, node.location.to_s, indent.of(node)
          self
        end

        def step(step, result)
          return if @last_step == step
          @last_step = step
          @child ||= StepsPrinter.new(formatter).before
          step_invocation = result.step_invocation(step_match(step), step, indent, node, runtime.configuration)
          runtime.step_visited step_invocation
          @child.step_invocation step_invocation, runtime, node
        end

        def after_step_hook(result)
          result.describe_exception_to formatter
        end

        def after
          @child.after if @child
          formatter.after_background(node)
          self
        end

        private

        def step_match(step)
          runtime.step_match(step.name)
        rescue Cucumber::Undefined
          NoStepMatch.new(step, step.name)
        end

        def indent
          @indent ||= Indent.new(node)
        end
      end

      # Printer to handle background steps for anything but the first scenario in a
      # feature. These steps should not be printed, but their results still need to
      # be recorded.
      class HiddenBackgroundPrinter < Struct.new(:formatter, :runtime, :node)

        def step(step, result)
          step_invocation = result.step_invocation(step_match(step), step, indent, node, runtime.configuration)
          runtime.step_visited step_invocation
        end

        def before_hook(*);end
        def after_hook(*);end
        def after_step_hook(*);end
        def examples_table(*);end
        def examples_table_row(*);end
        def before;self;end
        def after;self;end
        def after_test_case(*);end

        private

        def step_match(step)
          runtime.step_match(step.name)
        rescue Cucumber::Undefined
          NoStepMatch.new(step, step.name)
        end

        def indent
          @indent ||= Indent.new(node)
        end
      end

      ScenarioPrinter = Struct.new(:formatter, :runtime, :node, :before_hook_result) do
        def before
          formatter.before_feature_element(node)
          Legacy::Ast::Tags.new(node.tags).accept(formatter)
          formatter.scenario_name node.keyword, node.name, node.location.to_s, indent.of(node)
          before_hook_result.describe_exception_to(formatter) if before_hook_result
          self
        end

        def step(step, result)
          return if @last_step == step
          @child ||= StepsPrinter.new(formatter).before
          @last_step = step
          @last_step_result = result
          step_invocation = result.step_invocation(step_match(step), step, indent, background = nil, runtime.configuration)
          runtime.step_visited step_invocation
          @child.step_invocation step_invocation, runtime
        end

        def after_hook(result)
          @after_hook_result = result
        end

        def after_step_hook(result)
          result.describe_exception_to formatter
        end

        def after_test_case(*args)
          after
        end

        def after
          return if @done
          @child.after if @child
          # TODO - the last step result might not accurately reflect the
          # overall scenario result.
          scenario = last_step_result.scenario(node.name, node.location)
          @after_hook_result.describe_exception_to(formatter) if @after_hook_result
          formatter.after_feature_element(scenario)
          @done = true
          self
        end

        private

        def last_step_result
          @last_step_result || LegacyResultBuilder.new(Core::Test::Result::Unknown.new)
        end

        def step_match(step)
          runtime.step_match(step.name)
        rescue Cucumber::Undefined
          NoStepMatch.new(step, step.name)
        end

        def indent
          @indent ||= Indent.new(node)
        end
      end

      StepsPrinter = Struct.new(:formatter) do
        def before
          formatter.before_steps(nil)
          self
        end

        attr_reader :steps
        private :steps

        def step_invocation(step_invocation, runtime, background = nil)
          @steps ||= Legacy::Ast::StepInvocations.new
          steps << step_invocation
          StepPrinter.new(formatter, runtime, step_invocation).print
          self
        end

        def after
          @child.after if @child
          formatter.after_steps(steps)
          self
        end

      end

      StepPrinter = Struct.new(:formatter, :runtime, :step_invocation) do

        def print
          step_invocation.accept(formatter) do
            print_multiline_arg
          end
        end

        private

        def print_multiline_arg
          MultilineArgPrinter.new(formatter, runtime).print(step_invocation.multiline_arg)
        end

      end

      MultilineArgPrinter = Struct.new(:formatter, :runtime) do
        def print(node)
          # TODO - stop coupling to type
          return if node.is_a?( Cucumber::Core::Ast::EmptyMultilineArgument )
          formatter.node(:multiline_arg, node) do
            node.describe_to(self)
          end
        end

        def doc_string(doc_string)
          formatter.doc_string(doc_string)
        end

        def data_table(table)
          table.cells_rows.each do |row|
            TableRowPrinter.new(formatter, runtime, DataTableRow.new(row.map(&:value), row.line)).before.after
          end
        end

        DataTableRow = Struct.new(:values, :line) do
          def dom_id
            "row_#{line}"
          end
        end
      end

      ScenarioOutlinePrinter = Struct.new(:formatter, :runtime, :node) do
        extend Forwardable
        def_delegators :@child, :after_hook, :after_step_hook

        def before
          formatter.before_feature_element(node)
          Legacy::Ast::Tags.new(node.tags).accept(formatter)
          formatter.scenario_name node.keyword, node.name, node.location.to_s, indent.of(node)
          OutlineStepsPrinter.new(formatter, runtime, indent).print(node)
          self
        end

        def after_hook(result)
          @child.after_hook(result)
        end

        def step(node, result)
          @last_step_result = result
          @child.step(node, result)
        end

        def examples_table(examples_table)
          @child ||= ExamplesArrayPrinter.new(formatter, runtime).before
          @child.examples_table(examples_table)
        end

        def examples_table_row(node, before_hook_result)
          @child.examples_table_row(node, before_hook_result)
        end

        def after_test_case
          @child.after_test_case
        end

        def after
          @child.after if @child
          # TODO - the last step result might not accurately reflect the
          # overall scenario result.
          scenario_outline = last_step_result.scenario_outline(node.name, node.location)
          formatter.after_feature_element(scenario_outline)
          self
        end

        private

        def last_step_result
          @last_step_result || Core::Test::Result::Unknown.new
        end

        def indent
          @indent ||= Indent.new(node)
        end
      end

      OutlineStepsPrinter = Struct.new(:formatter, :runtime, :indent, :outline) do
        def print(node)
          node.describe_to self
          steps_printer.after
        end

        def scenario_outline(node, &descend)
          descend.call(self)
        end

        def outline_step(step)
          step_match = NoStepMatch.new(step, step.name)
          step_invocation = LegacyResultBuilder.new(Core::Test::Result::Skipped.new).
            step_invocation(step_match, step, indent, background = nil, runtime.configuration)
          steps_printer.step_invocation step_invocation, runtime, background = nil
        end

        def examples_table(*);end

        private

        def steps_printer
          @steps_printer ||= StepsPrinter.new(formatter).before
        end
      end

      ExamplesArrayPrinter = Struct.new(:formatter, :runtime) do
        extend Forwardable
        def_delegators :@child, :step, :after_hook, :after_step_hook, :after_test_case, :examples_table_row

        def before
          formatter.before_examples_array(:examples_array)
          self
        end

        def examples_table(examples_table)
          return if examples_table == @current
          @child.after if @child
          @child = ExamplesTablePrinter.new(formatter, runtime, examples_table).before
          @current = examples_table
        end

        def after
          @child.after if @child
          formatter.after_examples_array
          self
        end
      end

      ExamplesTablePrinter = Struct.new(:formatter, :runtime, :node) do
        extend Forwardable
        def_delegators :@child, :step, :after_hook, :after_step_hook, :after_test_case

        def before
          formatter.before_examples(node)
          formatter.examples_name(node.keyword, node.name)
          formatter.before_outline_table(legacy_table)
          TableRowPrinter.new(formatter, runtime, ExampleTableRow.new(node.header)).before.after
          self
        end

        def examples_table_row(examples_table_row, before_hook_result)
          return if examples_table_row == @current
          @child.after if @child
          row = ExampleTableRow.new(examples_table_row)
          @child = TableRowPrinter.new(formatter, runtime, row, nil, before_hook_result).before
          @current = examples_table_row
        end

        def after_test_case(*args)
          @child.after_test_case
        end

        def after
          @child.after if @child
          formatter.after_outline_table(node)
          formatter.after_examples(node)
          self
        end

        private

        def legacy_table
          LegacyTable.new(node)
        end

        class ExampleTableRow < SimpleDelegator
          def dom_id
            file_colon_line.gsub(/[\/\.:]/, '_')
          end
        end

        LegacyTable = Struct.new(:node) do
          def col_width(index)
            max_width = FindMaxWidth.new(index)
            node.describe_to max_width
            max_width.result
          end

          require 'gherkin/formatter/escaping'
          FindMaxWidth = Struct.new(:index) do
            include ::Gherkin::Formatter::Escaping

            def examples_table(table, &descend)
              @result = char_length_of(table.header.values[index])
              descend.call(self)
            end

            def examples_table_row(row, &descend)
              width = char_length_of(row.values[index])
              @result = width if width > result
            end

            def result
              @result ||= 0
            end

            private
            def char_length_of(cell)
              escape_cell(cell).unpack('U*').length
            end
          end
        end
      end

      TableRowPrinter = Struct.new(:formatter, :runtime, :node, :background, :before_hook_result) do
        def before
          before_hook_result.describe_exception_to(formatter) if before_hook_result
          formatter.before_table_row(node)
          self
        end

        def after_hook(result)
          @after_hook_result = result
        end

        def step(step, result)
          return if @last_step == step
          @last_step = step
          step_invocation = result.step_invocation(step_match(step), step, :indent_not_needed, background = nil, runtime.configuration)
          runtime.step_visited step_invocation
          @failed_step = step_invocation if result.status == :failed
          @status = step_invocation.status unless @status == :failed
        end

        def after_step_hook(result)
          @after_step_hook_result = result
        end

        def after_test_case(*args)
          after
        end

        def after
          return if @done
          @child.after if @child
          node.values.each do |value|
            formatter.before_table_cell(value)
            formatter.table_cell_value(value, @status || :skipped)
            formatter.after_table_cell(value)
          end
          formatter.after_table_row(legacy_table_row)
          @after_step_hook_result.describe_exception_to formatter if @after_step_hook_result
          @after_hook_result.describe_exception_to(formatter) if @after_hook_result
          if @failed_step
            formatter.exception @failed_step.exception, @failed_step.status
          end
          @done = true
          self
        end

        private

        def step_match(step)
          runtime.step_match(step.name)
        rescue Cucumber::Undefined
          NoStepMatch.new(step, step.name)
        end

        def legacy_table_row
          case node
          when DataTableRow
            LegacyTableRow.new(exception, @status)
          when ExampleTableRow
            LegacyExampleTableRow.new(exception, @status, node.values, node.location)
          end
        end

        LegacyTableRow = Struct.new(:exception, :status)
        LegacyExampleTableRow = Struct.new(:exception, :status, :cells, :location) do
          def name
            '| ' + cells.join(' | ') + ' |'
          end

          def failed?
            status == :failed
          end

          def line
            location.line
          end
        end

        def exception
          return nil unless @failed_step
          @failed_step.exception
        end

      end

      class Indent
        def initialize(node)
          @widths = []
          node.describe_to(self)
        end

        [:background, :scenario, :scenario_outline].each do |node_name|
          define_method(node_name) do |node, &descend|
          record_width_of node
          descend.call(self)
          end
        end

        [:step, :outline_step].each do |node_name|
          define_method(node_name) do |node|
            record_width_of node
          end
        end

        def examples_table(*); end

        def of(node)
          max - node.name.length - node.keyword.length
        end

        private

        def max
          @widths.max
        end

        def record_width_of(node)
          @widths << node.keyword.length + node.name.length + 1
        end
      end

      class LegacyResultBuilder
        attr_reader :status
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

        def pending(exception, *)
          @exception = exception
          @status = :pending
        end

        def exception(exception, *)
          @exception = exception
        end

        def append_to_exception_backtrace(line)
          @exception.set_backtrace(@exception.backtrace + [line.to_s]) if @exception
          return self
        end

        def duration(*); end

        def step_invocation(step_match, step, indent, background, configuration)
          Legacy::Ast::StepInvocation.new(step_match, @status, step_exception(step, configuration), indent, background, step)
        end

        def scenario(name, location)
          Legacy::Ast::Scenario.new(@status, name, location)
        end

        def scenario_outline(name, location)
          Legacy::Ast::ScenarioOutline.new(@status, name, location)
        end

        def describe_exception_to(formatter)
          formatter.exception(filtered_exception, @status) if @exception
        end

        private

        def step_exception(step, configuration)
          return filtered_step_exception(step) if @exception
          return nil unless @status == :undefined && configuration.strict?
          begin
            raise Cucumber::Undefined.new(step.name)
          rescue => exception
            @exception = exception
            filtered_step_exception(step)
          end
        end

        def filtered_exception
          BacktraceFilter.new(@exception.dup).exception
        end

        def filtered_step_exception(step)
          exception = filtered_exception
          exception.backtrace << StepBacktraceLine.new(step).to_s
          return exception
        end
      end

    end

    class StepBacktraceLine < Struct.new(:step)
      def to_s
        "#{step.location}:in `#{step.keyword}#{step.name}'"
      end
    end

    class BacktraceFilter
      BACKTRACE_FILTER_PATTERNS = \
        [/vendor\/rails|lib\/cucumber|bin\/cucumber:|lib\/rspec|gems\/|minitest|test\/unit|.gem\/ruby|lib\/ruby/]
      if(::Cucumber::JRUBY)
        BACKTRACE_FILTER_PATTERNS << /org\/jruby/
      end
      PWD_PATTERN = /#{::Regexp.escape(::Dir.pwd)}\//m

      def initialize(exception)
        @exception = exception
      end

      def exception
        return @exception if ::Cucumber.use_full_backtrace
        @exception.backtrace.each{|line| line.gsub!(PWD_PATTERN, "./")}

        filtered = (@exception.backtrace || []).reject do |line|
          BACKTRACE_FILTER_PATTERNS.detect { |p| line =~ p }
        end

        if ::ENV['CUCUMBER_TRUNCATE_OUTPUT']
          # Strip off file locations
          filtered = filtered.map do |line|
            line =~ /(.*):in `/ ? $1 : line
          end
        end

        @exception.set_backtrace(filtered)
        @exception
      end
    end

    # Adapters to pass to the legacy API formatters that provide the interface
    # of the old AST classes
    module Legacy
      module Ast

        Comments = Struct.new(:comments) do
          def accept(formatter)
            return if comments.empty?
            formatter.before_comment comments
            comments.each do |comment|
              formatter.comment_line comment.to_s.strip
            end
          end
        end

        StepInvocation = Struct.new(:step_match,
                                    :status,
                                    :exception,
                                    :indent,
                                    :background,
                                    :step) do
          extend Forwardable

          def_delegators :step, :keyword, :name, :multiline_arg, :location, :gherkin_statement

          def accept(formatter)
            formatter.before_step(self)
            formatter.before_step_result *step_result_attributes
            print_step_name(formatter)
            yield
            print_exception(formatter)
            formatter.after_step_result *step_result_attributes
            formatter.after_step(self)
          end

          def step_result_attributes
            [keyword, step_match, multiline_arg, status, exception, source_indent, background, file_colon_line]
          end

          def failed?
            status != :passed
          end

          def passed?
            status == :passed
          end

          def dom_id

          end

          def actual_keyword
            # TODO: This should return the keyword for the snippet
            # `actual_keyword` translates 'And', 'But', etc. to 'Given', 'When',
            # 'Then' as appropriate
            "Given"
          end

          def file_colon_line
            location.to_s
          end

          def backtrace_line
            step_match.backtrace_line
          end

          def step_invocation
            self
          end

          private

          def source_indent
            indent.of(self)
          end

          def print_step_name(formatter)
            formatter.step_name(
              keyword,
              step_match,
              status,
              source_indent,
              background,
              location.to_s)
          end

          def print_exception(formatter)
            return unless exception
            raise exception if ENV['FAIL_FAST']
            formatter.exception(exception, status)
          end
        end

        class StepInvocations < Array
          def failed?
            any?(&:failed?)
          end

          def passed?
            all?(&:passed?)
          end

          def status
            return :passed if passed?
            failed_step.status
          end

          def exception
            failed_step.exception if failed_step
          end

          private

          def failed_step
            detect(&:failed?)
          end
        end


        Tags = Struct.new(:tags) do
          def accept(formatter)
            formatter.before_tags tags
            tags.each do |tag|
              formatter.tag_name tag.name
            end
            formatter.after_tags tags
          end
        end

        Scenario = Struct.new(:status, :name, :location) do
          def backtrace_line(step_name = "#{name}", line = self.location.line)
            "#{location.on_line(line)}:in `#{step_name}'"
          end

          def failed?
            :failed == status
          end

          def line
            location.line
          end
        end

        ScenarioOutline = Struct.new(:status, :name, :location) do
          def backtrace_line(step_name = "#{name}", line = self.location.line)
            "#{location.on_line(line)}:in `#{step_name}'"
          end

          def failed?
            :failed == status
          end

          def line
            location.line
          end
        end

        Features = Struct.new(:duration)

      end

    end
  end
end
