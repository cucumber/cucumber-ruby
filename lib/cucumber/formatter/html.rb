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
          @builder.ol do
            super
          end
        end
      end

      def visit_feature_element(feature_element)
        @builder.div(:class => 'scenario') do
          super
        end
        @open_step_list = true
      end
      
      def visit_scenario_name(keyword, name, file_line, source_indent)
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

      def visit_steps(scenarios)
        @builder.ol do
          super
        end
      end

      def visit_step_name(keyword, step_name, status, step_definition, source_indent)
        @builder.li("#{keyword} #{step_name}", :class => status)
      end

      def visit_multiline_arg(multiline_arg, status)
        if Ast::Table === multiline_arg
          @builder.table do
            super(multiline_arg, status)
          end
        else
          @builder.p do
            super(multiline_arg, status)
          end
        end
      end

      def visit_table_row(table_row, status)
        @builder.tr do
          super(table_row, status)
        end
      end

      def visit_table_cell_value(value, width, status)
        @builder.td(value, :class => status)
      end

      private

      def inline_css
        @builder.style(:type => 'text/css') do
          @builder.text!(File.read(File.dirname(__FILE__) + '/cucumber.css'))
        end
      end

    end
  end
end