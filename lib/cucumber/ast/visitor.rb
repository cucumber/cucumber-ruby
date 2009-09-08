module Cucumber
  module Ast
    # Base class for formatters. This class just walks the tree depth first.
    # Just override the methods you care about. Remember to call super if you
    # override a method.
    class Visitor
      attr_accessor :options #:nodoc:
      attr_reader :step_mother #:nodoc:
      
      DEPRECATION_WARNING = "Cucumber::Ast::Visitor is deprecated and will be removed. You no longer need to inherit from this class."

      def initialize(step_mother)
        warn(DEPRECATION_WARNING)
        @step_mother = step_mother
        @options = {}
      end

      def visit_features(features)
        pause_until_visited
      end

      def visit_feature(feature)
        pause_until_visited
      end

      def visit_comment(comment)
        pause_until_visited
      end

      def visit_comment_line(comment_line)
        pause_until_visited
      end

      def visit_tags(tags)
        pause_until_visited
      end

      def visit_tag_name(tag_name)
        pause_until_visited
      end

      def visit_feature_name(name)
        pause_until_visited
      end

      # +feature_element+ is either Scenario or ScenarioOutline
      def visit_feature_element(feature_element)
        pause_until_visited
      end

      def visit_background(background)
        pause_until_visited
      end

      def visit_background_name(keyword, name, file_colon_line, source_indent)
        pause_until_visited
      end

      def visit_examples_array(examples_array)
        pause_until_visited
      end

      def visit_examples(examples)
        pause_until_visited
      end

      def visit_examples_name(keyword, name)
        pause_until_visited
      end

      def visit_outline_table(outline_table)
        pause_until_visited
      end

      def visit_scenario_name(keyword, name, file_colon_line, source_indent)
        pause_until_visited
      end

      def visit_steps(steps)
        pause_until_visited
      end

      def visit_step(step)
        pause_until_visited
      end

      def visit_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        pause_until_visited
      end

      def visit_step_name(keyword, step_match, status, source_indent, background) #:nodoc:
        pause_until_visited
      end

      def visit_multiline_arg(multiline_arg) #:nodoc:
        pause_until_visited
      end

      def visit_exception(exception, status) #:nodoc:
        pause_until_visited
      end

      def visit_py_string(string)
        pause_until_visited
      end

      def visit_table_row(table_row)
        pause_until_visited
      end

      def visit_table_cell(table_cell)
        pause_until_visited
      end

      def visit_table_cell_value(value, status)
        pause_until_visited
      end

      # Print +announcement+. This method can be called from within StepDefinitions.
      def announce(announcement)
        pause_until_visited
      end
      
      def run_before(method, *args)
        thread = Thread.new do
          self.send(method, *args)
        end
        
        @before_threads ||= []
        @before_threads << thread
        
        # first half of method run through, either to paused state or to end
        sleep 0.1 until thread.stop?
      end
      
      def run_after
        thread = @before_threads.pop
        thread.run if thread.alive?
        until !thread.alive?
          thread.run if thread.status == 'sleep'
        end
      end

      private
      
      def pause_until_visited
        sleep
      end
    end
  end
end
