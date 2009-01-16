require 'cucumber/formatter/console'

module Cucumber
  module Formatter
    # This formatter prints features to plain text - exactly how they were parsed,
    # just prettier. That means with proper indentation and alignment of table columns.
    #
    # If the output is STDOUT (and not a file), there are bright colours to watch too.
    #
    class Pretty < Ast::Visitor
      include Console

      def initialize(step_mother, io, options)
        super(step_mother)
        @io = (io == STDOUT) ? Kernel : io
        @options = options
      end

      def visit_features(features)
        super
        print_summary(@io, features)
      end

      def visit_feature(feature)
        @indent = 0
        feature.accept(self)
      end

      def visit_comment(comment)
        comment.accept(self)
      end

      def visit_comment_line(comment_line)
        @io.puts(comment_line.indent(@indent)) unless comment_line.blank?
      end

      def visit_tags(tags)
        tags.accept(self)
        @io.puts if @indent == 1
      end

      def visit_tag_name(tag_name)
        @io.print("@#{tag_name}".indent(@indent))
        @indent = 1
      end

      def visit_feature_name(name)
        @io.puts(name)
        @io.puts
      end

      def visit_feature_element(feature_element)
        @indent = 2
        feature_element.accept(self)
        @io.puts
      end

      def visit_examples(examples)
        examples.accept(self)
      end

      def visit_examples_name(keyword, name)
        @io.print("  #{keyword} #{name}\n")
        @indent = 4
      end

      def visit_scenario_name(keyword, name, file_line, comment_padding)
        line_comment = " # #{file_line}".indent(comment_padding)
        @io.puts("  #{keyword} #{name}" + format_string(line_comment, :comment))
      end

      def visit_step(step)
        @indent = 6
        step.accept(self)
      end

      def visit_step_name(gwt, step_name, status, step_invocation, comment_padding)
        formatted_step_name = format_step(gwt, step_name, status, step_invocation, comment_padding)
        @io.print("    " + formatted_step_name + "\n")
      end

      def visit_multiline_arg(multiline_arg, status)
        multiline_arg.accept(self, status)
      end

      def visit_table_row(table_row, status)
        @io.print '|'.indent(@indent)
        table_row.accept(self, status)
        @io.puts
      end

      def visit_py_string(string, status)
        s = "\"\"\"\n#{string}\n\"\"\"".indent(@indent)
        @io.print(format_string(s, status) + "\n")
      end

      def visit_table_cell(table_cell, status)
        table_cell.accept(self, status)
      end

      def visit_table_cell_value(value, width, status)
        @io.print(' ' + format_string(value.ljust(width), status) + ' |')
      end

      def visit_step_exception(e)
        @io.puts("      #{e.message} (#{e.class})")
        @io.puts('      ' + e.backtrace.join("\n      "))
      end

      private

      def format_step(gwt, step_name, status, step_invocation, comment_padding)
        line = if step_invocation
          comment = if @options[:source]
            c = (' # ' + step_invocation.file_colon_line).indent(comment_padding)
            format_string(c, :comment)
          else
            ''
          end
          gwt + " " + step_invocation.format_args(format_for(status, :param)) + comment
        else
          gwt + " " + step_name
        end
        format_string(line, status)
      end
    end
  end
end
