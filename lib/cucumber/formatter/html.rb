begin
  require 'builder'
rescue LoadError
  gem 'builder'
  require 'builder'
end

module Cucumber
  module Formatter
    class Html < Ast::Visitor
      def initialize(step_mother, io, options)
        super(step_mother)
        @builder = Builder::XmlMarkup.new(:target => io, :indent => 2)
      end
      
      def visit_features(features)
        # <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        @builder.declare!(
          :DOCTYPE,
          :html, 
          :PUBLIC, 
          '-//W3C//DTD XHTML 1.0 Strict//EN', 
          'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
        )
        @builder.html(:xmlns => 'http://www.w3.org/1999/xhtml') do
          @builder.head do
            @builder.title 'Cucumber'
            inline_css
          end
          @builder.body do
            @builder.div(:class => 'cucumber') do
              super
            end
          end
        end
      end

      def visit_feature(feature)
        @builder.div(:class => 'feature') do
          super
        end
      end

      def visit_feature_name(name)
        lines = name.split(/\r?\n/)
        @builder.h2(lines[0])
        @builder.p do
          lines[1..-1].each do |line|
            @builder.text!(line.strip)
            @builder.br
          end
        end
      end

      def visit_background(background)
        @builder.div(:class => 'background') do
          super
        end
      end

      def visit_background_name(keyword, name, file_colon_line, source_indent)
        @builder.h3("#{keyword} #{name}")
      end

      def visit_feature_element(feature_element)
        @builder.div(:class => 'scenario') do
          super
        end
        @open_step_list = true
      end
      
      def visit_scenario_name(keyword, name, file_colon_line, source_indent)
        @builder.h3("#{keyword} #{name}")
      end

      def visit_outline_table(outline_table)
        @builder.table do
          super(outline_table)
        end
      end

      def visit_examples_name(keyword, name)
        @builder.h4("#{keyword} #{name}")
      end

      def visit_steps(steps)
        @builder.ol do
          super
        end
      end

      def visit_step(step)
        @step_id = step.dom_id
        @builder.li(:id => @step_id) do
          super
        end
      end

      def visit_step_name(keyword, step_match, status, source_indent, background)
        @step_matches ||= []
        @skip_step = @step_matches.index(step_match)
        @step_matches << step_match

        unless @skip_step
          step_name = step_match.format_args(lambda{|param| "<span>#{param}</span>"})
          @builder.div(:class => status) do |div|
            div << "#{keyword} #{step_name}"
          end
        end
      end

      def visit_exception(exception, status)
        @builder.pre(format_exception(exception), :class => status)
      end

      def visit_multiline_arg(multiline_arg)
        return if @skip_step
        if Ast::Table === multiline_arg
          @builder.table do
            super
          end
        else
          super
        end
      end

      def visit_py_string(string, status)
        @builder.pre(:class => status) do |pre|
          pre << string
        end
      end

      def visit_table_row(table_row)
        @row_id = table_row.dom_id
        @col_index = 0
        @builder.tr(:id => @row_id) do
          super
        end
        if table_row.exception
          @builder.tr do
            @builder.td(:colspan => @col_index.to_s, :class => 'failed') do
              @builder.pre do |pre|
                pre << format_exception(table_row.exception)
              end
            end
          end
        end
      end

      def visit_table_cell_value(value, width, status)
        @builder.td(value, :class => status, :id => "#{@row_id}_#{@col_index}")
        @col_index += 1
      end

      def announce(announcement)
        @builder.pre(announcement, :class => 'announcement')
      end

      private

      def inline_css
        @builder.style(:type => 'text/css') do
          @builder.text!(File.read(File.dirname(__FILE__) + '/cucumber.css'))
        end
      end

      def format_exception(exception)
        (["#{exception.message} (#{exception.class})"] + exception.backtrace).join("\n")
      end
    end
  end
end
