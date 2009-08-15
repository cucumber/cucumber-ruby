require 'cucumber/formatter/ordered_xml_markup'

module Cucumber
  module Formatter
    class Junit < Cucumber::Ast::Visitor

      def initialize(step_mother, io, options)
        super(step_mother)
        raise "You *must* specify --out DIR for the junit formatter" unless String === io && File.directory?(io)
        @reportdir = io
        @options = options
      end

      def visit_feature(feature)
        @failures = @errors = @tests = 0
        @builder = OrderedXmlMarkup.new( :indent => 2 )
        @time = 0
        super

        @testsuite = OrderedXmlMarkup.new( :indent => 2 )
        @testsuite.instruct!
        @testsuite.testsuite(
          :failures => @failures,
          :errors => @errors,
          :tests => @tests,
          :time => "%.6f" % @time,
        :name => @feature_name ) do
          @testsuite << @builder.target!
        end

        basename = File.basename(feature.file)[0...-File.extname(feature.file).length]
        feature_filename = File.join(@reportdir, "TEST-#{basename}.xml")
        File.open(feature_filename, 'w') { |file| file.write(@testsuite.target!) }
      end

      def visit_background(name)
        @in_background = true
        super
        @in_background = false
      end

      def visit_feature_name(name)
        lines = name.split(/\r?\n/)
        @feature_name = lines[0].sub(/Feature\:/, '').strip
      end

      def visit_scenario_name(keyword, name, file_colon_line, source_indent)
        scenario_name = name.strip.delete(".\r\n")
        scenario_name = "Unnamed scenario" if name.blank?
        @scenario = scenario_name
        @outline = keyword.include?('Scenario Outline')
        @output = "Scenario#{ " outline" if @outline}: #{@scenario}\n\n"
      end

      def visit_steps(steps)
        return if @in_background
        start = Time.now
        super
        duration = Time.now - start
        unless @outline
          if steps.failed?
            steps.each { |step| @output += "#{step.keyword} #{step.name}\n" }
            @output += "\nMessage:\n"
          end
          build_testcase(duration, steps.status, steps.exception)
        end
      end

      def visit_outline_table(outline_table)
        @header_row = true
        super(outline_table)
      end

      def visit_table_row(table_row)
        if @outline
          start = Time.now
          super(table_row)
          duration = Time.now - start
          unless @header_row
            name_suffix = " (outline example : #{table_row.name})"
            if table_row.failed?
              @output += "Example row: #{table_row.name}\n"
              @output += "\nMessage:\n"
            end
            build_testcase(duration, table_row.status, table_row.exception,  name_suffix)
          end
        else
          super(table_row)
        end
        @header_row = false
      end

      private

        def build_testcase(duration, status, exception = nil, suffix = "")
          @time += duration
          classname = "#{@feature_name}.#{@scenario}"
          name = "#{@scenario}#{suffix}"
          failed = (status == :failed || (status == :pending && @options[:strict]))
          #puts "FAILED:!!#{failed}"
          if status == :passed || failed
            @builder.testcase(:classname => classname, :name => name, :time => "%.6f" % duration) do
              if failed
                @builder.failure(:message => "#{status.to_s} #{name}", :type => status.to_s) do
                  @builder.text! @output
                  @builder.text!(format_exception(exception)) if exception
                end
                @failures += 1
              end
            end
            @tests += 1
          end
        end

        def format_exception(exception)
          (["#{exception.message} (#{exception.class})"] + exception.backtrace).join("\n")
        end
    end
  end
end
