require 'cucumber/formatters/ansicolor'

module Cucumber
  module Formatter
    class Pretty
      extend Formatters::ANSIColor
      FORMATS = Hash.new{|hash, format| hash[format] = method(format).to_proc}
      
      def initialize(io)
        @io = io
      end

      def visit_feature(feature)
        @indent = 0
        feature.accept(self)
      end

      def visit_comment(comment)
        @io.write(comment.indented(@indent))
      end

      def visit_tags(tags)
        tag_line = tags.tag_names.map do |tag_name|
          (" " * @indent) + "@#{tag_name}"
        end.join(" ")
        @io.write(tag_line)
        @io.write("\n")
      end

      def visit_feature_name(name)
        @io.write("Feature: #{name}\n\n")
      end

      def visit_feature_element(feature_element)
        @indent = 2
        feature_element.accept(self)
      end

      def visit_scenario_name(name)
        @io.write("  Scenario: #{name}\n")
      end

      def visit_step(step)
        @io.write("    " + step.format(FORMATS) + "\n")
        if step.error
          @io.write("      " + step.error.message + "\n")
          @io.write("      " + step.error.cucumber_backtrace.join("\n      ") + "\n")
        end
      end
    end
  end
end
