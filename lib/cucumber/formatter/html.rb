require 'erb'
begin
  require 'builder'
rescue LoadError
  gem 'builder'
  require 'builder'
end
require 'cucumber/formatter/duration'

module Cucumber
  module Formatter
    class Html < Ast::Visitor
      include ERB::Util # for the #h method
      include Duration

      def initialize(step_mother, io, options)
        super(step_mother)
        @options = options
        @builder = create_builder(io)
      end
      
      def create_builder(io)
        Builder::XmlMarkup.new(:target => io, :indent => 2)
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
            @builder.meta(:content => 'text/html;charset=utf-8')
            @builder.title 'Cucumber'
            inline_css
          end
          @builder.body do
            @builder.div(:class => 'cucumber') do
              super
              @builder.div(format_duration(features.duration), :class => 'duration')
            end
          end
        end
      end

      def visit_comment(comment)
        @builder.pre(:class => 'comment') do
          super
        end
      end

      def visit_comment_line(comment_line)
        @builder.text!(comment_line.strip + "\n")
      end

      def visit_feature(feature)
        @exceptions = []
        @builder.div(:class => 'feature') do
          super
        end
      end

      def visit_tag_name(tag_name)
        @builder.span("@#{tag_name}", :class => 'tag')
      end

      def visit_feature_name(name)
        lines = name.split(/\r?\n/)
        @builder.h2 do |h2|
          @builder.span(lines[0], :class => 'val')
        end
        @builder.p do
          lines[1..-1].each do |line|
            @builder.text!(line.strip)
            @builder.br
          end
        end
      end

      def visit_background(background)
        @builder.div(:class => 'background') do
          @in_background = true
          super
          @in_background = nil
        end
      end

      def visit_background_name(keyword, name, file_colon_line, source_indent)
        @listing_background = true
        @builder.h3 do |h3|
          @builder.span(keyword, :class => 'keyword')
          @builder.text!(' ')
          @builder.span(name, :class => 'val')
        end
      end

      def visit_feature_element(feature_element)
        css_class = {
          Ast::Scenario        => 'scenario',
          Ast::ScenarioOutline => 'scenario outline'
        }[feature_element.class]
        @builder.div(:class => css_class) do
          super
        end
        @open_step_list = true
      end
      
      def visit_scenario_name(keyword, name, file_colon_line, source_indent)
        @listing_background = false
        @builder.h3 do
          @builder.span(keyword, :class => 'keyword')
          @builder.text!(' ')
          @builder.span(name, :class => 'val')
        end
      end

      def visit_outline_table(outline_table)
        @outline_row = 0
        @builder.table do
          super(outline_table)
        end
        @outline_row = nil
      end

      def visit_examples(examples)
        @builder.div(:class => 'examples') do
          super(examples)
        end
      end

      def visit_examples_name(keyword, name)
        @builder.h4 do
          @builder.span(keyword, :class => 'keyword')
          @builder.text!(' ')
          @builder.span(name, :class => 'val')
        end
      end

      def visit_steps(steps)
        @builder.ol do
          super
        end
      end

      def visit_step(step)
        @step_id = step.dom_id
        super
      end

      def visit_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        if exception
          return if @exceptions.index(exception)
          @exceptions << exception
        end
        return if status != :failed && @in_background ^ background
        @status = status
        @builder.li(:id => @step_id, :class => "step #{status}") do
          super(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        end
      end

      def visit_step_name(keyword, step_match, status, source_indent, background)
        @step_matches ||= []
        background_in_scenario = background && !@listing_background
        @skip_step = @step_matches.index(step_match) || background_in_scenario
        @step_matches << step_match

        unless @skip_step
          build_step(keyword, step_match, status)
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

      def visit_py_string(string)
        @builder.pre(:class => 'val') do |pre|
          @builder.text!(string)
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
        @outline_row += 1 if @outline_row
      end

      def visit_table_cell_value(value, width, status)
        cell_type = @outline_row == 0 ? :th : :td
        attributes = {:id => "#{@row_id}_#{@col_index}", :class => 'val'}
        attributes[:class] += " #{status}" if status
        build_cell(cell_type, value, attributes)
        @col_index += 1
      end
      
      def announce(announcement)
        @builder.pre(announcement, :class => 'announcement')
      end

      protected
      
      def build_step(keyword, step_match, status)
        step_name = step_match.format_args(lambda{|param| %{<span class="param">#{param}</span>}})
        @builder.div do |div|
          @builder.span(keyword, :class => 'keyword')
          @builder.text!(' ')
          @builder.span(:class => 'step val') do |name|
            name << h(step_name).gsub(/&lt;span class=&quot;(.*?)&quot;&gt;/, '<span class="\1">').gsub(/&lt;\/span&gt;/, '</span>')
          end
        end
      end
      
      def build_cell(cell_type, value, attributes)
        @builder.__send__(cell_type, value, attributes)
      end

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
