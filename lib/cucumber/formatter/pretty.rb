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
        @exceptions = []
        @indent = 0
      end

      def visit_features(features)
        super
        print_summary(features) unless @options[:autoformat]
      end

      def visit_feature(feature)
        @exceptions = []
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
        @scenario_indent = 2
        super
        @io.puts
        @io.flush
      end

      def visit_background(background)
        @indent = 2
        @scenario_indent = 2
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
        names = name.empty? ? [name] : name.split("\n")
        @io.puts("\n    #{keyword} #{names[0]}")
        names[1..-1].each {|s| @io.puts "      #{s}" }
        @io.flush
        @indent = 6
        @scenario_indent = 6
      end

      def visit_scenario_name(keyword, name, file_colon_line, source_indent)
        visit_feature_element_name(keyword, name, file_colon_line, source_indent)
      end

      def visit_feature_element_name(keyword, name, file_colon_line, source_indent)
        @io.puts if @scenario_indent == 6
        names = name.empty? ? [name] : name.split("\n")
        line = "#{keyword} #{names[0]}".indent(@scenario_indent)
        @io.print(line)
        if @options[:source]
          line_comment = " # #{file_colon_line}".indent(source_indent)
          @io.print(format_string(line_comment, :comment))
        end
        @io.puts
        names[1..-1].each {|s| @io.puts "    #{s}"}
        @io.flush
      end

      def visit_step(step)
        @indent = 6
        super
      end

      def visit_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        if exception
          return if @exceptions.index(exception)
          @exceptions << exception
        end
        return if status != :failed && @in_background ^ background
        @status = status
        super
      end

      def visit_step_name(keyword, step_match, status, source_indent, background)
        source_indent = nil unless @options[:source]
        formatted_step_name = format_step(keyword, step_match, status, source_indent)
        @io.puts(formatted_step_name.indent(@scenario_indent + 2))
      end

      def visit_multiline_arg(multiline_arg)
        return if @options[:no_multiline]
        super
      end

      def visit_exception(exception, status)
        print_exception(exception, status, @indent)
        @io.flush
      end

      def visit_table_row(table_row)
        @io.print @delim.indent(@indent)
        super
        @io.puts
        if table_row.exception && !@exceptions.index(table_row.exception)
          print_exception(table_row.exception, :failed, @indent) 
        end
      end

      def visit_py_string(string)
        s = %{"""\n#{string}\n"""}.indent(@indent)
        s = s.split("\n").map{|l| l =~ /^\s+$/ ? '' : l}.join("\n")
        @io.puts(format_string(s, @status))
        @io.flush
      end

      def visit_table_cell_value(value, width, status)
        status ||= @status || :passed
        @io.print(' ' + format_string((value.to_s || '').ljust(width), status) + ::Term::ANSIColor.reset(" #{@delim}"))
        @io.flush
      end

      private

      def print_summary(features)
        print_stats(features)
        print_snippets(@options)
        print_passing_wip(@options)
      end

    end
  end
end
