require 'cucumber/formatter/console'
require 'fileutils'

module Cucumber
  module Formatter
    # This formatter prints features to plain text - exactly how they were parsed,
    # just prettier. That means with proper indentation and alignment of table columns.
    #
    # If the output is STDOUT (and not a file), there are bright colours to watch too.
    #
    class Pretty < Ast::Visitor
      include FileUtils
      include Console
      attr_writer :indent

      def initialize(step_mother, io, options, delim='|')
        super(step_mother)
        @io = io
        @options = options
        @delim = delim
        @indent = 0
      end

      def visit_features(features)
        super
        print_summary unless @options[:autoformat]
      end

      def visit_feature(feature)
        @indent = 0
        if @options[:autoformat]
          file = File.join(@options[:autoformat], feature.file)
          dir = File.dirname(file)
          mkdir_p(dir) unless File.directory?(dir)
          File.open(file, Cucumber.file_mode('w')) do |io|
            @io = io
            super
          end
        else
          super
        end
      end

      def visit_comment(comment)
        comment.accept(self)
      end

      def visit_comment_line(comment_line)
        unless comment_line.blank?
          @io.puts(comment_line.indent(@indent)) 
          @io.flush
        end
      end

      def visit_tags(tags)
        tags.accept(self)
        if @indent == 1
          @io.puts 
          @io.flush
        end
      end

      def visit_tag_name(tag_name)
        tag = format_string("@#{tag_name}", :tag).indent(@indent)
        @io.print(tag)
        @io.flush
        @indent = 1
      end

      def visit_feature_name(name)
        @io.puts(name)
        @io.puts
        @io.flush
      end

      def visit_feature_element(feature_element)
        @indent = 2
        super
        @io.puts
        @io.flush
      end

      def visit_background(background)
        @indent = 2
        @in_background = true
        super
        @in_background = nil
        @io.puts
        @io.flush
      end

      def visit_background_name(keyword, name, file_colon_line, source_indent)
        visit_feature_element_name(keyword, name, file_colon_line, source_indent)
      end

      def visit_examples_name(keyword, name)
        @io.puts("\n  #{keyword} #{name}")
        @io.flush
        @indent = 4
      end

      def visit_scenario_name(keyword, name, file_colon_line, source_indent)
        visit_feature_element_name(keyword, name, file_colon_line, source_indent)
      end

      def visit_feature_element_name(keyword, name, file_colon_line, source_indent)
        line = "  #{keyword} #{name}"
        @io.print(line)
        if @options[:source]
          line_comment = " # #{file_colon_line}".indent(source_indent)
          @io.print(format_string(line_comment, :comment))
        end
        @io.puts
        @io.flush
      end

      def visit_step(step)
        @indent = 6
        super
      end

      def visit_step_name(keyword, step_match, status, source_indent, background)
        @step_matches ||= []
        non_failed_background_step_outside_background = !@in_background && background && (status != :failed)
        @skip_step = @step_matches.index(step_match) || non_failed_background_step_outside_background
        @step_matches << step_match
        
        unless(@skip_step)
          source_indent = nil unless @options[:source]
          formatted_step_name = format_step(keyword, step_match, status, source_indent)
          @io.puts("    " + formatted_step_name)
        end
      end

      def visit_multiline_arg(multiline_arg)
        return if @options[:no_multiline] || @skip_step
        super
      end

      def visit_exception(exception, status)
        return if @skip_step
        print_exception(exception, status, @indent)
        @io.flush
      end

      def visit_table_row(table_row)
        @io.print @delim.indent(@indent)
        super
        @io.puts
        print_exception(table_row.exception, :failed, @indent) if table_row.exception
      end

      def visit_py_string(string, status)
        s = "\"\"\"\n#{string}\n\"\"\"".indent(@indent)
        s = s.split("\n").map{|l| l =~ /^\s+$/ ? '' : l}.join("\n")
        @io.puts(format_string(s, status))
        @io.flush
      end

      def visit_table_cell(table_cell)
        super
      end

      def visit_table_cell_value(value, width, status)
        @io.print(' ' + format_string((value.to_s || '').ljust(width), status) + " #{@delim}")
        @io.flush
      end

      private

      def print_summary
        print_counts
        print_snippets(@options)
      end

    end
  end
end
