require 'forwardable'
require 'delegate'
require 'cucumber/errors'

module Cucumber
  module Reports

    class FormatterWrapper < BasicObject
      attr_reader :formatters
      private :formatters

      def initialize(formatters)
        @formatters = formatters
      end

      def node(node_name, node, &block)
        method_missing "before_#{node_name}", node
        block.call if block
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
      def initialize(runtime, formatters)
        super runtime, FormatterWrapper.new(formatters)
      end

      extend Forwardable

      def_delegators :formatter,
        :embed,
        :ask,
        :puts

      attr_accessor :cursor
      private :cursor
      def before_test_case(test_case, &continue)
        self.cursor = Cursor.new(runtime, test_case)

        cursor.accept(formatter) do |new_formatter|
          @current_formatter = new_formatter
          continue.call
        end
      end

      def before_test_step(test_step)
        @current_step = Step.for(test_step, cursor)
        test_step.describe_source_to(cursor)
        self
      end

      def after_test_step(test_step, result)
        @cursor.result(result)
        @current_step.accept(@current_formatter, result)
        self
      end

      def after_test_case(test_case, result)
        record_test_case_result(test_case, result)
        self
      end

      def done
      end

      def record_test_case_result(test_case, result)
        scenario = LegacyResultBuilder.new(result).scenario(test_case.name, test_case.location)
        runtime.record_result(scenario)
      end

      class Cursor
        attr_reader :runtime
        private     :runtime
        def initialize(runtime, test_case)
          @runtime = runtime
          test_case.describe_source_to(self)
        end

        def accept(formatter, &block)
          Features.new.accept(formatter) do
            Feature.new.accept(formatter) do
              FeatureElement.new(@current_scenario, self).accept(formatter) do
                Steps.new.accept(formatter, &block)
              end
            end
          end
        end

        def hook
        end

        def step(step, *args)
          @current_step = step
          self
        end

        def feature(feature, *args)
          self
        end

        def scenario(scenario, *args)
          @current_scenario = scenario
          self
        end

        def result(result, *args)
          @current_result = result
          self
        end

        def legacy_scenario(name, location)
          LegacyResultBuilder.new(@current_result).scenario(name, location)
        end

        def legacy_step_result_attributes
          LegacyResultBuilder.new(@current_result).
            step_invocation(
              step_match(@current_step),
              @current_step,
              Indent.new(@current_step)
            ).
            step_result_attributes
        end

        private
        def step_match(step)
          runtime.step_match(step.name)
        rescue Cucumber::Undefined
          NoStepMatch.new(step, step.name)
        end
      end

      class Features
        def accept(formatter)
          formatter.before_features(nil)

          yield if block_given?

          formatter.after_features
          self
        end
      end

      class Feature
        def accept(formatter)
          formatter.before_feature
          formatter.node(:tags, nil)
          formatter.feature_name

          yield if block_given?

          formatter.after_feature
          self
        end
      end

      class FeatureElement
        include Cucumber.initializer(:scenario, :cursor)

        def accept(visitor)
          visitor.before_feature_element
          visitor.node(:tags, nil)
          visitor.scenario_name

          yield if block_given?

          visitor.after_feature_element cursor.legacy_scenario(scenario.name, scenario.location)
          self
        end
      end

      class Steps
        def accept(visitor)
          visitor = StepsFormatter.new(visitor)
          visitor.before_steps

          yield visitor if block_given?

          visitor.after_steps
        end

        require 'delegate'
        class StepsFormatter < SimpleDelegator
          attr_reader :messages
          def initialize(visitor)
            @visitor = visitor
            @messages = []
            @recording = true
            super(visitor)
          end

          def before_steps(*args)
            messages << [:before_steps, args]
            self
          end

          def exception(*args)
            if @recording
              messages.unshift [:exception, args]
            else
              @visitor.exception(*args)
            end
            self
          end

          def before_step(*args)
            playback
            @visitor.before_step(*args)
            self
          end

          def playback
            if @recording
              messages.each { |m, args| @visitor.public_send(m, *args) }
              @messages = []
              @recording = false
            end
          end

          def after_step
            @visitor.after_step
            @recording = true
          end

          def after_steps
            @visitor.after_steps
            playback
          end

        end
      end

      class Step
        def self.for(test_step, cursor)
          return new(cursor) if test_step.is_a? Core::Test::Step
          return HookStep.new
        end

        attr_reader :cursor
        private     :cursor
        def initialize(cursor)
          @cursor = cursor
        end

        def accept(visitor, result)
          visitor.before_step
          yield if block_given?
          visitor.before_step_result
          visitor.step_name
          visitor.exception if result.failed?

          visitor.after_step_result *cursor.legacy_step_result_attributes
          visitor.after_step
          self
        end

        class HookStep
          def accept(visitor, result)
            visitor.exception if result.failed?
            yield if block_given?
            self
          end
        end
      end


      ##### MANKY
      require 'cucumber/core/test/timer'
      FeaturesPrinter = Struct.new(:formatter, :runtime) do
        def before
          timer.start
          formatter.before_features(nil)
          self
        end

        def hook(result)
          LegacyResultBuilder.new(result).describe_exception_to(formatter)
        end

        def feature(node, *)
          return if node == @current_feature
          @child.after if @child
          @child = FeaturePrinter.new(formatter, runtime, node).before
          @current_feature = node
        end

        def background(node, result)
          @child.background(node, result)
        end

        def step(node, result)
          # TODO: Create StepInvocation here and send it down.
          @child.step(node, result)
        end

        def scenario(node, result)
          @child.scenario(node, result)
        end

        def scenario_outline(node, result)
          @child.scenario_outline(node, result)
        end

        def examples_table(node, result)
          @child.examples_table(node, result)
        end

        def examples_table_row(node, result)
          @child.examples_table_row(node, result)
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

      FeaturePrinter = Struct.new(:formatter, :runtime, :feature) do
        def before
          formatter.before_feature(feature)
          Legacy::Ast::Comments.new(feature.comments).accept(formatter)
          Legacy::Ast::Tags.new(feature.tags).accept(formatter)
          formatter.feature_name feature.keyword, indented(feature.name) # TODO: change the core's new AST to return name and description separately instead of this lumped-together field
          self
        end

        def background(node, *)
          if background_printed?
            @child.after
            @child = HiddenBackgroundPrinter.new(formatter, runtime, node)
          else
            @child ||= BackgroundPrinter.new(formatter, runtime, node).before
          end
        end

        def background_printed?
          @current_feature_element
        end

        def scenario(node, *)
          return if node == @current_feature_element
          @child.after if @child
          @child = ScenarioPrinter.new(formatter, runtime, node).before
          @current_feature_element = node
        end

        def step(node, result)
          @child.step(node, result)
        end

        def scenario_outline(node, *)
          return if node == @current_feature_element
          @child.after if @child
          @child = ScenarioOutlinePrinter.new(formatter, runtime, node).before
          @current_feature_element = node
        end

        def examples_table(node, result)
          @child.examples_table(node, result)
        end

        def examples_table_row(node, result)
          @child.examples_table_row(node, result)
        end

        def after
          @child.after if @child
          formatter.after_feature(feature)
          self
        end

        private

        def indented(nasty_old_conflation_of_name_and_description)
          indent = ""
          nasty_old_conflation_of_name_and_description.split("\n").map do |l|
            s = "#{indent}#{l}"
            indent = "  "
            s
          end.join("\n")
        end
      end

      BackgroundPrinter = Struct.new(:formatter, :runtime, :background) do

        def before
          formatter.before_background background
          formatter.background_name background.keyword, background.name, background.location.to_s, indent.of(background)
          self
        end

        def step(step, result)
          @child ||= StepsPrinter.new(formatter).before
          step_invocation = LegacyResultBuilder.new(result).step_invocation(step_match(step), step, indent, background)
          runtime.step_visited step_invocation
          @child.step_invocation step_invocation, runtime, background
        end

        def after
          @child.after if @child
          formatter.after_background(background)
          self
        end

        private

        def step_match(step)
          runtime.step_match(step.name)
        rescue Cucumber::Undefined
          NoStepMatch.new(step, step.name)
        end

        def indent
          @indent ||= Indent.new(background)
        end
      end

      # Printer to handle background steps for anything but the first scenario in a 
      # feature. These steps should not be printed, but their results still need to 
      # be recorded.
      class HiddenBackgroundPrinter < Struct.new(:formatter, :runtime, :background)
        def step(step, result)
          step_invocation = LegacyResultBuilder.new(result).step_invocation(step_match(step), step, indent, background)
          runtime.step_visited step_invocation
        end

        def method_missing(*args);end

        private

        def step_match(step)
          runtime.step_match(step.name)
        rescue Cucumber::Undefined
          NoStepMatch.new(step, step.name)
        end

        def indent
          @indent ||= Indent.new(background)
        end
      end

      ScenarioPrinter = Struct.new(:formatter, :runtime, :node) do
        def before
          formatter.before_feature_element(node)
          Legacy::Ast::Tags.new(node.tags).accept(formatter)
          formatter.scenario_name node.keyword, node.name, node.location.to_s, indent.of(node)
          self
        end

        def step(step, result)
          @child ||= StepsPrinter.new(formatter).before
          @last_step_result = result
          step_invocation = LegacyResultBuilder.new(result).step_invocation(step_match(step), step, indent, background = nil)
          runtime.step_visited step_invocation
          @child.step_invocation step_invocation, runtime
        end

        def after
          @child.after if @child
          # TODO - the last step result might not accurately reflect the
          # overall scenario result.
          scenario = LegacyResultBuilder.new(last_step_result).scenario(node.name, node.location)
          formatter.after_feature_element(scenario)
          self
        end

        private

        def last_step_result
          @last_step_result || Core::Test::Result::Unknown.new
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
        def before
          formatter.before_feature_element(node)
          Legacy::Ast::Tags.new(node.tags).accept(formatter)
          formatter.scenario_name node.keyword, node.name, node.location.to_s, indent.of(node)
          OutlineStepsPrinter.new(formatter, runtime, indent).print(node)
          self
        end

        def step(node, result)
          @last_step_result = result
          @child.step(node, result)
        end

        def examples_table(examples_table, *)
          @child ||= ExamplesArrayPrinter.new(formatter, runtime).before
          @child.examples_table(examples_table)
        end

        def examples_table_row(node, result)
          @last_step_resule = result
          @child.examples_table_row(node, result)
        end

        def after
          @child.after if @child
          # TODO - the last step result might not accurately reflect the
          # overall scenario result.
          scenario_outline = LegacyResultBuilder.new(last_step_result).scenario_outline(node.name, node.location)
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
          descend.call
        end

        def outline_step(step)
          step_match = NoStepMatch.new(step, step.name)
          step_invocation = LegacyResultBuilder.new(Core::Test::Result::Skipped.new).
            step_invocation(step_match, step, indent, background = nil)
          steps_printer.step_invocation step_invocation, runtime, background = nil
        end

        def examples_table(*);end

        private

        def steps_printer
          @steps_printer ||= StepsPrinter.new(formatter).before
        end
      end

      ExamplesArrayPrinter = Struct.new(:formatter, :runtime) do
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

        def examples_table_row(node, result)
          @child.examples_table_row(node, result)
        end

        def step(node, result)
          @child.step(node, result)
        end

        def after
          @child.after if @child
          formatter.after_examples_array
          self
        end
      end

      ExamplesTablePrinter = Struct.new(:formatter, :runtime, :node) do
        def before
          formatter.before_examples(node)
          formatter.examples_name(node.keyword, node.name)
          formatter.before_outline_table(legacy_table)
          TableRowPrinter.new(formatter, runtime, ExampleTableRow.new(node.header)).before.after
          self
        end

        def examples_table_row(examples_table_row, *)
          return if examples_table_row == @current
          @child.after if @child
          @child = TableRowPrinter.new(formatter, runtime, ExampleTableRow.new(examples_table_row)).before
          @current = examples_table_row
        end

        def step(node, result)
          @child.step(node, result)
        end

        class ExampleTableRow < SimpleDelegator
          def dom_id
            file_colon_line.gsub(/[\/\.:]/, '_')
          end
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
              descend.call
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

      TableRowPrinter = Struct.new(:formatter, :runtime, :node, :background) do
        def before
          formatter.before_table_row(node)
          self
        end

        def step(step, result)
          step_invocation = LegacyResultBuilder.new(result).step_invocation(step_match(step), step, :indent_not_needed)
          runtime.step_visited step_invocation
          @failed_step = step_invocation if result.failed?
          @status = step_invocation.status unless @status == :failed
        end

        def after
          @child.after if @child
          node.values.each do |value|
            formatter.before_table_cell(value)
            formatter.table_cell_value(value, @status || :skipped)
            formatter.after_table_cell(value)
          end
          formatter.after_table_row(legacy_table_row)
          if @failed_step
            formatter.exception @failed_step.exception, @failed_step.status
          end
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
            descend.call
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

        def duration(*); end

        def step_invocation(step_match, step, indent, background = nil)
          Legacy::Ast::StepInvocation.new(step_match, @status, @exception, indent, background, step)
        end

        def scenario(name, location)
          Legacy::Ast::Scenario.new(@status, name, location)
        end

        def scenario_outline(name, location)
          Legacy::Ast::ScenarioOutline.new(@status, name, location)
        end

        def describe_exception_to(formatter)
          formatter.exception(@exception, @status) if @exception
        end

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
                                        ex = exception.dup
                                        ex.backtrace << "#{step.location}:in `#{step.keyword}#{step.name}'"
                                        filter_backtrace(ex)
                                        formatter.exception(ex, status)
                                      end

                                      private

                                      BACKTRACE_FILTER_PATTERNS = [/vendor\/rails|lib\/cucumber|bin\/cucumber:|lib\/rspec|gems\/|minitest|test\/unit|.gem\/ruby|lib\/ruby/]
                                      if(Cucumber::JRUBY)
                                        BACKTRACE_FILTER_PATTERNS << /org\/jruby/
                                      end
                                      PWD_PATTERN = /#{Regexp.escape(Dir.pwd)}\//m

                                      # This is to work around double ":in " segments in JRuby backtraces. JRuby bug?
                                      def filter_backtrace(e)
                                        return e if Cucumber.use_full_backtrace
                                        e.backtrace.each{|line| line.gsub!(PWD_PATTERN, "./")}

                                        filtered = (e.backtrace || []).reject do |line|
                                          BACKTRACE_FILTER_PATTERNS.detect { |p| line =~ p }
                                        end

                                        if ENV['CUCUMBER_TRUNCATE_OUTPUT']
                                          # Strip off file locations
                                          filtered = filtered.map do |line|
                                            line =~ /(.*):in `/ ? $1 : line
                                          end
                                        end

                                        e.set_backtrace(filtered)
                                        e
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
