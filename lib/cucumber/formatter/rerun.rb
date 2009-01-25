module Cucumber
  module Formatter
    class Rerun < Ast::Visitor
      def initialize(step_mother, io, options)
        super(step_mother)
        @io = io
        @file_names = []
        @file_lines = Hash.new{|h,k| h[k] = []}
      end

      def visit_features(features)
        super
        files = @file_names.uniq.map do |file|
          lines = @file_lines[file]
          "#{file}:#{lines.join(':')}"
        end
        @io.puts files.join(' ')
      end

      def visit_feature_element(feature_element)
        @rerun = false
        super
        if @rerun
          file, line = *feature_element.file_line.split(':')
          @file_lines[file] << line
          @file_names << file
        end
      end

      def visit_step_name(keyword, step_name, status, step_definition, source_indent)
        @rerun = true if [:failed].index(status)
      end
    end
  end
end