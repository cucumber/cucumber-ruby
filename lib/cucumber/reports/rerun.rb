require 'cucumber/formatter/io'

module Cucumber
  module Reports
    class Rerun
      extend Formatter::Io

      def self.configure(runtime, path_or_io, options)
        new(ensure_io(path_or_io, "rerun"))
      end

      def initialize(io)
        @io = io
        @failures = {}
      end

      def after_test_case(test_case, result)
        return if result.passed?
        @failures[test_case.location.file] ||= []
        @failures[test_case.location.file] << test_case.location.line
      end

      def done
        return if @failures.empty?
        @io.print file_failures.join(' ')
      end

      [:before_test_case, :before_test_step, :after_test_step].each do |method|
        define_method(method) { |*| }
      end

      private
      def file_failures
        @failures.map { |file, lines| [file, lines].join(':') }
      end
    end
  end
end
