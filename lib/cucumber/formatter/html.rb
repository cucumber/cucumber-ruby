require 'cucumber/formatter/ordered_xml_markup'
require 'cucumber/formatter/duration'
require 'xml'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format html</tt>
    class Html
      include ERB::Util # for the #h method
      include Duration

      def initialize(step_mother, io, options)
        @io = io
        @options = options
        @buffer = {}
        @builder = create_builder(@io)
      end
      
      def before_visit_features(features)
        start_buffering :features
      end
      
      def after_visit_features(features)
        stop_buffering :features
        # <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        builder.declare!(
          :DOCTYPE,
          :html, 
          :PUBLIC, 
          '-//W3C//DTD XHTML 1.0 Strict//EN', 
          'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
        )
        builder.html(:xmlns => 'http://www.w3.org/1999/xhtml') do
          builder.head do
            builder.meta(:content => 'text/html;charset=utf-8')
            builder.title 'Cucumber'
            # inline_css
          end
          builder.body do
            builder.div(:class => 'cucumber') do
              builder << buffer[:features]
              builder.div(format_duration(features.duration), :class => 'duration')
            end
          end
        end
      end
      
      def before_visit_feature(feature)
        start_buffering :feature
      end
      
      def after_visit_feature(feature)
        stop_buffering :feature
        @exceptions = []
        builder.div(:class => 'feature') do
          builder << buffer[:feature]
        end
      end

      def before_visit_comment(comment)
        start_buffering :comment
      end

      def after_visit_comment(comment)
        stop_buffering :comment
        builder.pre(:class => 'comment') do
          builder << buffer[:comment]
        end
      end

      def visit_comment_line(comment_line)
        builder.text!(comment_line)
        builder.br
      end
      
      def after_visit_tags(tags)
        @tag_spacer = nil
      end
      
      def visit_tag_name(tag_name)
        builder.text!(@tag_spacer) if @tag_spacer
        @tag_spacer = ' '
        builder.span("@#{tag_name}", :class => 'tag')
      end

      def visit_feature_name(name)
        lines = name.split(/\r?\n/)
        return if lines.empty?
        builder.h2 do |h2|
          builder.span(lines[0], :class => 'val')
        end
        builder.p(:class => 'narrative') do
          lines[1..-1].each do |line|
            builder.text!(line.strip)
            builder.br
          end
        end
      end

      def before_visit_background(background)
        @in_background = true
        start_buffering :background
      end
      
      def after_visit_background(background)
        stop_buffering :background
        @in_background = nil
        builder.div(:class => 'background') do
          builder << buffer[:background]
        end
      end

      def visit_background_name(keyword, name, file_colon_line, source_indent)
        @listing_background = true
        builder.h3 do |h3|
          builder.span(keyword, :class => 'keyword')
          builder.text!(' ')
          builder.span(name, :class => 'val')
        end
      end

      def before_visit_feature_element(feature_element)
        start_buffering :feature_element
      end
      
      def after_visit_feature_element(feature_element)
        stop_buffering :feature_element
        css_class = {
          Ast::Scenario        => 'scenario',
          Ast::ScenarioOutline => 'scenario outline'
        }[feature_element.class]

        builder.div(:class => css_class) do
          builder << buffer[:feature_element]
        end
        @open_step_list = true
      end

      def visit_scenario_name(keyword, name, file_colon_line, source_indent)
        @listing_background = false
        builder.h3 do
          builder.span(keyword, :class => 'keyword')
          builder.text!(' ')
          builder.span(name, :class => 'val')
        end
      end
      
      def before_visit_outline_table(outline_table)
        @outline_row = 0
        start_buffering :outline_table
      end
      
      def after_visit_outline_table(outline_table)
        stop_buffering :outline_table
        builder.table do
          builder << buffer[:outline_table]
        end
        @outline_row = nil
      end

      def before_visit_examples(examples)
        start_buffering :examples
      end
      
      def after_visit_examples(examples)
        stop_buffering :examples
        builder.div(:class => 'examples') do
          builder << buffer[:examples]
        end
      end

      def visit_examples_name(keyword, name)
        builder.h4 do
          builder.span(keyword, :class => 'keyword')
          builder.text!(' ')
          builder.span(name, :class => 'val')
        end
      end
      # # 
      # # def visit_steps(steps)
      # #   @builder.ol do
      # #     super
      # #   end
      # # end
      # # 
      # # def visit_step(step)
      # #   @step_id = step.dom_id
      # #   super
      # # end
      # # 
      # # def visit_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
      # #   if exception
      # #     return if @exceptions.index(exception)
      # #     @exceptions << exception
      # #   end
      # #   return if status != :failed && @in_background ^ background
      # #   @status = status
      # #   @builder.li(:id => @step_id, :class => "step #{status}") do
      # #     super(keyword, step_match, multiline_arg, status, exception, source_indent, background)
      # #   end
      # # end
      # # 
      def visit_step_name(keyword, step_match, status, source_indent, background)
        @step_matches ||= []
        background_in_scenario = background && !@listing_background
        @skip_step = @step_matches.index(step_match) || background_in_scenario
        @step_matches << step_match
      
        unless @skip_step
          build_step(keyword, step_match, status)
        end
      end
      # # 
      # # def visit_exception(exception, status)
      # #   @builder.pre(format_exception(exception), :class => status)
      # # end
      # # 
      # # def visit_multiline_arg(multiline_arg)
      # #   return if @skip_step
      # #   if Ast::Table === multiline_arg
      # #     @builder.table do
      # #       super
      # #     end
      # #   else
      # #     super
      # #   end
      # # end
      # # 
      # # def visit_py_string(string)
      # #   @builder.pre(:class => 'val') do |pre|
      # #     @builder << string.gsub("\n", '&#x000A;')
      # #   end
      # # end
      # # 
      # # def visit_table_row(table_row)
      # #   @row_id = table_row.dom_id
      # #   @col_index = 0
      # #   @builder.tr(:id => @row_id) do
      # #     super
      # #   end
      # #   if table_row.exception
      # #     @builder.tr do
      # #       @builder.td(:colspan => @col_index.to_s, :class => 'failed') do
      # #         @builder.pre do |pre|
      # #           pre << format_exception(table_row.exception)
      # #         end
      # #       end
      # #     end
      # #   end
      # #   @outline_row += 1 if @outline_row
      # # end
      # # 
      # # def visit_table_cell_value(value, status)
      # #   cell_type = @outline_row == 0 ? :th : :td
      # #   attributes = {:id => "#{@row_id}_#{@col_index}", :class => 'val'}
      # #   attributes[:class] += " #{status}" if status
      # #   build_cell(cell_type, value, attributes)
      # #   @col_index += 1
      # # end
      # # 
      # # def announce(announcement)
      # #   @builder.pre(announcement, :class => 'announcement')
      # # end
      # # 
      # # protected
      # # 
      
      private
      
      def build_step(keyword, step_match, status)
        step_name = step_match.format_args(lambda{|param| %{<span class="param">#{param}</span>}})
        builder.div do |div|
          builder.span(keyword, :class => 'keyword')
          builder.text!(' ')
          builder.span(:class => 'step val') do |name|
            name << h(step_name).gsub(/&lt;span class=&quot;(.*?)&quot;&gt;/, '<span class="\1">').gsub(/&lt;\/span&gt;/, '</span>')
          end
        end
      end
      # # 
      # # def build_cell(cell_type, value, attributes)
      # #   @builder.__send__(cell_type, value, attributes)
      # # end
      # # 
      # # def inline_css
      # #   @builder.style(:type => 'text/css') do
      # #     @builder.text!(File.read(File.dirname(__FILE__) + '/cucumber.css'))
      # #   end
      # # end
      # # 
      # # def format_exception(exception)
      # #   h((["#{exception.message} (#{exception.class})"] + exception.backtrace).join("\n"))
      # # end
      # #
      
      def builder
        @builder
      end
      
      def buffer
        @buffer
      end

      def start_buffering(label)
        @buffer[label] ||= ''
        @parent_builder ||= {}
        @parent_builder[label] = @builder
        @builder = create_builder(@buffer[label])
      end
      
      def stop_buffering(label)
        @builder = @parent_builder[label]
      end
      
      def create_builder(io)
        OrderedXmlMarkup.new(:target => io, :indent => 2)
      end
    end
  end
end
