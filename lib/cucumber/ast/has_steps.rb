require 'enumerator'
require 'gherkin/tag_expression'

module Cucumber
  module Ast
    module HasSteps #:nodoc:
      attr_reader :gherkin_statement, :raw_steps, :title, :description
      def gherkin_statement(statement=nil)
        @gherkin_statement ||= statement
      end

      def attach_steps(steps)
        steps.each do |step| 
          step.feature_element = self
        end
      end

      def first_line_length
        name_line_lengths[0]
      end

      def text_length
        name_line_lengths.max
      end

      def name_line_lengths
        if name.strip.empty?
          [Ast::Step::INDENT + @keyword.unpack('U*').length + ': '.length]
        else
          name.split("\n").enum_for(:each_with_index).map do |line, line_number|
            if line_number == 0
              Ast::Step::INDENT + @keyword.unpack('U*').length + ': '.length + line.unpack('U*').length
            else
              Ast::Step::INDENT + Ast::Step::INDENT + line.unpack('U*').length
            end
          end
        end
      end

      def matches_scenario_names?(scenario_name_regexps)
        scenario_name_regexps.detect{|n| n =~ name}
      end

      def backtrace_line(step_name = "#{@keyword}: #{name}", line = self.line)
        "#{location.on_line(line)}:in `#{step_name}'"
      end

      def source_indent(text_length)
        max_line_length - text_length
      end

      def max_line_length
        steps.max_line_length(self)
      end

      def accept_hook?(hook)
        Gherkin::TagExpression.new(hook.tag_expressions).evaluate(source_tags)
      end

      def source_tag_names
        source_tags.map { |tag| tag.name }
      end

      def source_tags
        @tags.tags.to_a + feature_tags.tags.to_a
      end

      def language
        @language || raise("Language is required for a #{self.class}")
      end

    end
  end
end
