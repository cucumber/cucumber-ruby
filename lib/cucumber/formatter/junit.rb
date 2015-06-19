require 'builder'
require 'cucumber/formatter/io'
require 'cucumber/formatter/interceptor'
require 'fileutils'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format junit</tt>
    class Junit

      include Io

      class UnNamedFeatureError < StandardError
        def initialize(feature_file)
          super("The feature in '#{feature_file}' does not have a name. The JUnit XML format requires a name for the testsuite element.")
        end
      end

      def initialize(_runtime, io, options)
        @reportdir = ensure_dir(io, "junit")
        @options = options
      end

      def before_test_case(test_case)
        unless same_feature_as_previous_test_case?(test_case.feature)
          end_feature if @current_feature
          start_feature(test_case.feature)
        end
        @failing_step_source = nil
        # In order to fill out <system-err/> and <system-out/>, we need to
        # intercept the $stderr and $stdout
        @interceptedout = Interceptor::Pipe.wrap(:stdout)
        @interceptederr = Interceptor::Pipe.wrap(:stderr)
      end

      def after_test_step(test_step, result)
        return if @failing_step_source

        @failing_step_source = test_step.source.last unless result.ok?(@options[:strict])
      end

      def after_test_case(test_case, result)
        test_case_name = NameBuilder.new(test_case)
        scenario = test_case_name.scenario_name
        scenario_designation = "#{scenario}#{test_case_name.name_suffix}"
        output = create_output_string(test_case, scenario, result, test_case_name.row_name)
        build_testcase(result, scenario_designation, output)

        Interceptor::Pipe.unwrap! :stdout
        Interceptor::Pipe.unwrap! :stderr
      end

      def done
        end_feature if @current_feature
      end

      private

      def same_feature_as_previous_test_case?(feature)
        @current_feature && @current_feature.file == feature.file && @current_feature.location == feature.location
      end

      def start_feature(feature)
        raise UnNamedFeatureError.new(feature.file) if feature.name.empty?
        @current_feature = feature
        @failures = @errors = @tests = @skipped = 0
        @builder = Builder::XmlMarkup.new(:indent => 2)
        @time = 0
      end

      def end_feature
        @testsuite = Builder::XmlMarkup.new(:indent => 2)
        @testsuite.instruct!
        @testsuite.testsuite(
          :failures => @failures,
          :errors => @errors,
          :skipped => @skipped,
          :tests => @tests,
          :time => "%.6f" % @time,
          :name => @current_feature.name ) do
          @testsuite << @builder.target!
        end

        write_file(feature_result_filename(@current_feature.file), @testsuite.target!)
      end

      def create_output_string(test_case, scenario, result, row_name)
        output = "#{test_case.keyword}: #{scenario}\n\n"
        return output if result.ok?(@options[:strict])
        if test_case.keyword == "Scenario"
          output += "#{@failing_step_source.keyword}" unless hook?(@failing_step_source)
          output += "#{@failing_step_source.name}\n"
        else
          output += "Example row: #{row_name}\n"
        end
        output + "\nMessage:\n"
      end

      def hook?(step)
        ["Before hook", "After hook", "AfterStep hook"].include? step.name
      end

      def build_testcase(result, scenario_designation, output)
        duration = ResultBuilder.new(result).test_case_duration
        @time += duration
        classname = @current_feature.name
        name = scenario_designation

        @builder.testcase(:classname => classname, :name => name, :time => "%.6f" % duration) do
          if !result.passed? && result.ok?(@options[:strict])
            @builder.skipped
            @skipped += 1
          elsif !result.passed?
            status = result.to_sym
            exception = get_backtrace_object(result)
            @builder.failure(:message => "#{status} #{name}", :type => status) do
              @builder.cdata! output
              @builder.cdata!(format_exception(exception)) if exception
            end
            @failures += 1
          end
          @builder.tag!('system-out') do
            @builder.cdata! strip_control_chars(@interceptedout.buffer.join)
          end
          @builder.tag!('system-err') do
            @builder.cdata! strip_control_chars(@interceptederr.buffer.join)
          end
        end
        @tests += 1
      end

      def get_backtrace_object(result)
        if result.failed?
          return result.exception
        elsif result.backtrace
          return result
        else
          return nil
        end
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
      attr_reader :scenario_name, :name_suffix, :row_name

      def initialize(test_case)
        @name_suffix = ""
        @row_name = ""
        test_case.describe_source_to self
      end

      def feature(*)
        self
      end

      def scenario(scenario)
        @scenario_name = (scenario.name.nil? || scenario.name == "") ? "Unnamed scenario" : scenario.name
        self
      end

      def scenario_outline(outline)
        @scenario_name = (outline.name.nil? || outline.name == "") ? "Unnamed scenario outline" : outline.name
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
      attr_reader :test_case_duration
      def initialize(result)
        @test_case_duration = 0
        result.describe_to(self)
      end

      def passed(*) end

      def failed(*) end

      def undefined(*) end

      def skipped(*) end

      def pending(*) end

      def exception(*) end

      def duration(duration, *)
        duration.tap { |duration| @test_case_duration = duration.nanoseconds / 10**9.0 }
      end
    end

  end
end
