require 'cucumber/formatter/io'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format rerun</tt>
    #
    # This formatter keeps track of all failing features and print out their location.
    # Example:
    #
    #   features/foo.feature:34 features/bar.feature:11:76:81
    #
    # This formatter is used by AutoTest - it will use the output to decide what
    # to run the next time, simply passing the output string on the command line.
    #
    class Rerun
      include Io

      def initialize(runtime, path_or_io, options)
        @io = ensure_io(path_or_io, "rerun")
        @options = options
        @file_names = []
        @file_colon_lines = Hash.new{|h,k| h[k] = []}
      end

      def before_feature(feature_element)
        @lines = []
        @file = feature_element.file
      end

      def after_feature(*)
        unless @lines.empty?
          after_first_time do
            @io.print ' '
          end
          @io.print "#{@file}:#{@lines.join(':')}"
          @io.flush
        end
      end

      def after_features(features)
        @io.close
      end

      def before_feature_element(feature_element)
        @rerun = false
      end

      def after_feature_element(feature_element)
        if (@rerun || feature_element.failed?) && !(Ast::ScenarioOutline === feature_element)
          @lines << feature_element.line
        end
      end

      def after_table_row(table_row)
        return unless @in_examples and Cucumber::Ast::OutlineTable::ExampleRow === table_row
        unless @header_row
          if table_row.failed?
            @rerun = true
            @lines << table_row.line
          end
        end

        @header_row = false if @header_row
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
      end

      def step_name(keyword, step_match, status, source_indent, background, file_colon_line)
        @rerun = true if [:failed, :pending, :undefined].index(status)
      end

    private

      def after_first_time
        yield if @not_first_time
        @not_first_time = true
      end
    end
  end
end
