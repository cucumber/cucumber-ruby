require 'cucumber/formatter/junit'
require 'hpricot'

module Cucumber
  module Formatter
    class JunitAggregate < Junit

      class TestSuite
        attr_reader :test_cases
        attr_accessor :name

        def initialize
          @test_cases = {}
        end

        def self.from_document(document)
          node       = document / '/'
          test_suite = self.new
          (node / '//testcase').each do |testcase_node|
            test_case = TestCase.from_node testcase_node
            test_suite.set test_case
          end
          test_suite
        end

        def set testcase
          key                  = TestSuite.build_id testcase.classname, testcase.name
          self.test_cases[key] = testcase
        end

        def failures
          failures = 0
          @test_cases.each_value do |test_case|
            failures += 1 if test_case.failed? and (test_case.failure.how == :failed)
          end
          failures
        end

        def errors
          errors = 0
          @test_cases.each_value do |test_case|
            errors += 1 if test_case.failed? and (test_case.failure.how == :error)
          end
          errors
        end

        def tests
          @test_cases.size
        end

        def time
          time = 0.0
          @test_cases.each_value do |test_case|
            time += test_case.time
          end
          time
        end

        def self.build_id(classname, name)
          Digest::MD5::hexdigest("#{classname}.#{name}")
        end

        def get_testcase(classname, name)
          key = TestSuite.build_id(classname, name)
          return @test_cases[key] if @test_cases.has_key? key
          TestCase.new classname, name
        end

        def build_document
          xml = Builder::XmlMarkup.new(:indent=>2)
          xml.instruct!
          xml.testsuite(:name     => self.name,
          :errors   => self.errors,
          :failures => self.failures,
          :tests    => self.tests,
          :time     => "%.6f" % self.time) {
            test_cases.each_value do |testcase|
              testcase.build_node xml
            end
          }
          xml.target!
        end
      end

      class TestCase
        attr_reader :name, :classname
        attr_accessor :time, :failure

        def initialize classname, name
          @name      = name
          @classname = classname
          @time      = 0.0
          @failure   = nil
        end

        def failed?
          !self.failure.nil?
        end

        def self.from_node node
          testcase      = self.new(node.attributes['classname'], node.attributes['name'])
          testcase.time = node.attributes['time'].to_f
          failure_node  = (node / 'failure').first
          unless failure_node.nil?
            failure          = Failure.from_node failure_node
            testcase.failure = failure
          end
          testcase
        end

        def build_node xml
          xml.testcase(:classname => self.classname,
          :name      => self.name,
          :time      => "%.6f" % self.time) {
            unless self.failure.nil?
              self.failure.build_node xml
            end
          }
        end
      end

      class Failure
        attr_reader :how, :message, :data

        def initialize type, message
          @how     = type
          @message = message
          @data    = []
        end

        def build_node xml
          xml.failure(:type => self.how.to_s, :message => self.message) {
            self.data.each do |datum|
              xml.cdata! datum
            end
          }
        end

        def self.from_node node
          failure = Failure.new node.attributes['type'], node.attributes['message']
          node.each_child do |datum|
            failure.data << datum.content unless datum.content.strip.empty?
          end
          failure
        end
      end

      def before_feature(feature)
        @current_feature = feature
        begin
          read_report
          @test_suite = TestSuite.from_document @doc
        rescue
          @test_suite = TestSuite.new
        end
      end

      def after_feature(feature)
        @test_suite.name = @feature_name
        write_report(report_filename, @test_suite)
      end

      def after_steps(steps)
        return if @in_background || @in_examples

        duration = Time.now - @steps_start
        testcase = @test_suite.get_testcase classname, @scenario
        testcase.failure = nil
        if steps.failed?
          steps.each { |step| @output += "#{step.keyword}#{step.name}\n" }
          @output += "\nMessage:\n"
          failure = Failure.new(step.status, "#{step.status.to_s} #{@scenario}")
          failure.data << @output
          failure.data << format_exception(steps.exception) if step.exception
          testcase.failure = failure
        end
        testcase.time = duration
        @test_suite.set testcase
      end

      def after_table_row(table_row)
        return unless @in_examples

        duration = Time.now - @table_start
        unless @header_row
          name_suffix = " (outline example : #{table_row.name})"
          testcase    = @test_suite.get_testcase classname, name = "#{@scenario}#{name_suffix}"
          testcase.failure = nil
          if table_row.failed?
            @output += "Example row: #{table_row.name}\n"
            @output += "\nMessage:\n"
            failure = Failure.new(table_row.status, "#{table_row.status.to_s} #{name}")
            failure.data << @output
            failure.data << format_exception(table_row.exception) if table_row.exception
            testcase.failure = failure
          end
          testcase.time = duration
          @test_suite.set testcase
        else
          key = TestSuite.build_id(classname, @scenario)
          @test_suite.test_cases.delete(key) if @test_suite.test_cases.has_key? key
        end


        @header_row = false if @header_row
      end

      def classname
        "#{@feature_name}.#{@scenario}"
      end

      private

      def report_filename
        feature_basename = File.basename(@current_feature.file, '.feature')
        File.join(@reportdir, "TEST-#{feature_basename}.xml")
      end

      def format_exception(exception)
        (["#{exception.message} (#{exception.class})"] + exception.backtrace).join("\n")
      end

      private
      def read_report
        File.open(report_filename, 'r') do |report|
          @doc = Hpricot.XML(report)
        end
      end

      def write_report(report_filname, testsuie)
        File.open(report_filename, 'w') do |report|
          report.write test_suite.build_document
        end        
      end
    end
  end
end