require 'cucumber/formatters/ansicolor'

module Cucumber
  module Formatter
    # This formatter prints features to plain text - exactly how they were parsed,
    # just prettier. That means with proper indentation and alignment of table columns.
    #
    # If the output is STDOUT (and not a file), there are bright colours to watch too.
    #
    class Pretty
      extend Formatters::ANSIColor
      FORMATS = Hash.new{|hash, format| hash[format] = method(format).to_proc}

      def initialize(step_mother, io)
        @step_mother, @io = step_mother, io
      end

      def visit_feature(feature)
        @indent = 0
        feature.accept(self)
      end

      def visit_comment(comment)
        comment.accept(self)
      end

      def visit_comment_line(comment_line)
        indent
        @io.write(comment_line)
        @io.write("\n")
      end

      def visit_tags(tags)
        indent
        @tag_space = ""
        tags.accept(self)
        @io.write("\n")
      end

      def visit_tag_name(tag_name)
        @io.write(@tag_space)
        @io.write("@#{tag_name}")
        @tag_space = " "
      end

      def visit_feature_name(name)
        @io.write("Feature: #{name}\n\n")
      end

      def visit_feature_element(feature_element)
        @indent = 2
        feature_element.accept(self)
      end

      def visit_examples(examples)
        examples.accept(self)
      end

      def visit_examples_name(keyword, name)
        @io.write("  #{keyword} #{name}\n")
        @indent = 4
      end

      def visit_scenario_name(keyword, name)
        @io.write("  #{keyword} #{name}\n")
      end

      def visit_step(step)
        @indent = 6
        step.accept(self)
      end

      def visit_step_name(gwt, step_name, status, step_invocation, comment_padding)
        formatted_step_name = format_step(gwt, step_name, status, step_invocation, comment_padding)
        @io.write("    " + formatted_step_name + "\n")
      end

      def visit_inline_arg(inline_arg, status)
        inline_arg.accept(self, status)
      end

      def visit_table_row(table_row, status)
        indent
        @io.write '|'
        table_row.accept(self, status)
        @io.puts
      end

      def visit_py_string(string, status)
        indent
        s = "\"\"\"\n" + string.split("\n", -1).map{|line| (' ' * @indent) + line}.join("\n") + "\"\"\""
        @io.write(format_string(s, status) + "\n")
      end

      def visit_table_cell(table_cell, status)
        table_cell.accept(self, status)
      end

      def visit_table_cell_value(value, width, status)
        @io.write(' ' + format_string(value.ljust(width), status) + ' |')
      end

      def visit_step_exception(e)
        @io.write('      ' + e.message + "\n")
        @io.write('      ' + e.cucumber_backtrace.join("\n      ") + "\n")
      end

      private

      def indent
        @io.write(' ' * @indent)
      end

      def format_step(gwt, step_name, status, step_invocation, comment_padding)
        line = if step_invocation
        comment = format_string(' # ' + step_invocation.file_colon_line, :comment)
        padding = " " * comment_padding
        gwt + " " + step_invocation.format_args(format_for(status, :param)) + padding + comment
      else
        gwt + " " + step_name
      end
      format_string(line, status)
    end

    def format_string(string, status)
      fmt = format_for(status)
      if Proc === fmt
        fmt.call(string)
      else
        fmt % string
      end
    end

    def format_for(*keys)
      key = keys.join('_').to_sym
      fmt = FORMATS[key]
      raise "No format for #{key.inspect}: #{FORMATS.inspect}" if fmt.nil?
      fmt
    end
  end
end
end
