require 'builder'

module Cucumber
  module Formatter
    class Html < Ast::Visitor
      def initialize(step_mother, io, options)
        super(step_mother)
        @builder = Builder::XmlMarkup.new(:target => io, :indent => 2)
      end
      
      def visit_features(features)
        @builder.html do
          @builder.head do
            @builder.title 'Cucumber'
          end
          @builder.body do
            super
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

      def visit_feature_element(feature_element)
        @builder.div(:class => 'scenario') do
          super
        end
        @open_step_list = true
      end
      
      def visit_scenario_name(keyword, name, file_line, source_indent)
        @builder.h3("#{keyword} #{name}")
      end

      def visit_steps(scenarios)
        @builder.ol do
          super
        end
      end

      def visit_step_name(keyword, step_name, status, step_definition, source_indent)
        @builder.li("#{keyword} #{step_name}")
      end

    end
  end
end