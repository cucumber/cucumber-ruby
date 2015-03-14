require 'builder'
require 'cucumber/formatter/io'
require 'cucumber/formatter/interceptor'
require 'fileutils'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format junit</tt>
    class Junit

      # TODO: remove coupling to types
      AST_SCENARIO_OUTLINE = Core::Ast::ScenarioOutline
      AST_EXAMPLE_ROW = LegacyApi::Ast::ExampleTableRow

      include Io

      class UnNamedFeatureError < StandardError
        def initialize(feature_file)
          super("The feature in '#{feature_file}' does not have a name. The JUnit XML format requires a name for the testsuite element.")
        end
      end

      def initialize(runtime, io, options)
        @reportdir = ensure_dir(io, "junit")
        @options = options
      end

      def before_feature(feature)
        @current_feature = feature
        @failures = @errors = @tests = @skipped = 0
        @builder = Builder::XmlMarkup.new( :indent => 2 )
        @time = 0
        # In order to fill out <system-err/> and <system-out/>, we need to
        # intercept the $stderr and $stdout
        @interceptedout = Interceptor::Pipe.wrap(:stdout)
        @interceptederr = Interceptor::Pipe.wrap(:stderr)
      end

      def before_feature_element(feature_element)
        @in_examples = AST_SCENARIO_OUTLINE === feature_element
        @steps_start = Time.now
      end

      def after_feature(feature)
        @testsuite = Builder::XmlMarkup.new( :indent => 2 )
        @testsuite.instruct!
        @testsuite.testsuite(
          :failures => @failures,
          :errors => @errors,
          :skipped => @skipped,
          :tests => @tests,
          :time => "%.6f" % @time,
          :name => @feature_name ) do
          @testsuite << @builder.target!
          @testsuite.tag!('system-out') do
            @testsuite.cdata! strip_control_chars(@interceptedout.buffer.join)
          end
          @testsuite.tag!('system-err') do
            @testsuite.cdata! strip_control_chars(@interceptederr.buffer.join)
          end
        end

        write_file(feature_result_filename(feature.file), @testsuite.target!)

        Interceptor::Pipe.unwrap! :stdout
        Interceptor::Pipe.unwrap! :stderr
      end

      def before_background(*args)
        @in_background = true
      end

      def after_background(*args)
        @in_background = false
      end

      def feature_name(keyword, name)
        raise UnNamedFeatureError.new(@current_feature.file) if name.empty?
        lines = name.split(/\r?\n/)
        @feature_name = lines[0]
      end

      def scenario_name(keyword, name, file_colon_line, source_indent)
        @scenario = (name.nil? || name == "") ? "Unnamed scenario" : name.split("\n")[0]
        @output = "#{keyword}: #{@scenario}\n\n"
      end

      def before_steps(steps)
      end

      def after_steps(steps)
        return if @in_background || @in_examples

        duration = Time.now - @steps_start
        if steps.failed?
          steps.each { |step| @output += "#{step.keyword}#{step.name}\n" }
          @output += "\nMessage:\n"
        end
        build_testcase(duration, steps.status, steps.exception)
      end

      def before_examples(*args)
        @header_row = true
        @in_examples = true
      end

      def after_examples(*args)
        @in_examples = false
      end

      def before_table_row(table_row)
        return unless @in_examples

        @table_start = Time.now
      end

      def after_table_row(table_row)
        return unless @in_examples and AST_EXAMPLE_ROW === table_row
        duration = Time.now - @table_start
        unless @header_row
          name_suffix = " (outline example : #{table_row.name})"
          if table_row.failed?
            @output += "Example row: #{table_row.name}\n"
            @output += "\nMessage:\n"
          end
          build_testcase(duration, table_row.status, table_row.exception, name_suffix)
        end

        @header_row = false if @header_row
      end

      def before_test_case(test_case)
        if @options[:expand] and test_case.keyword == "Scenario Outline"
          @exception = nil
        end
      end

      def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background, file_colon_line)
        if @options[:expand] and @in_examples
          if not @exception and exception
            @exception = exception
          end
        end
      end

      def after_test_case(test_case, result)
        if @options[:expand] and test_case.keyword == "Scenario Outline"
          test_case_name = NameBuilder.new(test_case)
          @scenario = test_case_name.outline_name
          @output = "#{test_case.keyword}: #{@scenario}\n\n"
          if result.failed?
            @output += "Example row: #{test_case_name.row_name}\n"
            @output += "\nMessage:\n"
          end
          test_case_result = ResultBuilder.new(result)
          build_testcase(test_case_result.test_case_duration, test_case_result.status, @exception, test_case_name.name_suffix)
        end
      end

      private

      def build_testcase(duration, status, exception = nil, suffix = "")
        @time += duration
        classname = @feature_name
        name = "#{@scenario}#{suffix}"
        pending = [:pending, :undefined].include?(status) && (!@options[:strict])

        @builder.testcase(:classname => classname, :name => name, :time => "%.6f" % duration) do
          if status == :skipped || pending
            @builder.skipped
            @skipped += 1
          elsif status != :passed
            @builder.failure(:message => "#{status.to_s} #{name}", :type => status.to_s) do
              @builder.cdata! @output
              @builder.cdata!(format_exception(exception)) if exception
            end
            @failures += 1
          end
          @builder.tag!('system-out')
          @builder.tag!('system-err')
        end
        @tests += 1
      end

      def format_exception(exception)
        (["#{exception.message} (#{exception.class})"] + exception.backtrace).join("\n")
      end

      def feature_result_filename(feature_file)
        File.join(@reportdir, "TEST-#{basename(feature_file)}.xml")
      end

      def basename(feature_file)
        File.basename(feature_file.gsub(/[\\\/]/, '-'), '.feature')
      end

      def write_file(feature_filename, data)
        File.open(feature_filename, 'w') { |file| file.write(data) }
      end

      # strip control chars from cdata, to make it safe for external parsers
      def strip_control_chars(cdata)
        cdata.scan(/[[:print:]\t\n\r]/).join
      end
      
    end

    class NameBuilder
      attr_reader :outline_name, :name_suffix, :row_name

      def initialize(test_case)
        test_case.describe_source_to self
      end

      def feature(*)
        self
      end

      def scenario(*)
        self
      end

      def scenario_outline(outline)
        @outline_name = outline.name
        self
      end

      def examples_table(*)
        self
      end

      def examples_table_row(row)
        @row_name = '| ' + row.values.join(' | ') + ' |'
        @name_suffix = " (outline example : #{@row_name})"
        self
      end
    end

    class ResultBuilder
      attr_reader :status, :test_case_duration
      def initialize(result)
        @test_case_duration = 0
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

      def pending(*)
        @status = :pending
      end

      def exception(*)
      end

      def duration(duration, *)
        duration.tap { |duration| @test_case_duration = duration.nanoseconds / 10 ** 9.0 }
      end
    end

  end
end
