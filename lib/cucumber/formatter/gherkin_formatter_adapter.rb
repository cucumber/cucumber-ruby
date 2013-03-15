require 'cucumber/formatter/io'
require 'gherkin/formatter/argument'

module Cucumber
  module Formatter
    # Adapts Cucumber formatter events to Gherkin formatter events
    # This class will disappear when Cucumber is based on Gherkin's model.
    class GherkinFormatterAdapter
      def initialize(gherkin_formatter, print_empty_match)
        @gf = gherkin_formatter
        @print_empty_match = print_empty_match
      end

      def before_feature(feature)
        @gf.uri(feature.file)
        @gf.feature(feature.gherkin_statement)
      end

      def before_background(background)
        @outline = false
        @gf.background(background.gherkin_statement)
      end

      def before_feature_element(feature_element)
        case(feature_element)
        when Ast::Scenario
          @outline = false
          @gf.scenario(feature_element.gherkin_statement)
        when Ast::ScenarioOutline
          @outline = true
          @gf.scenario_outline(feature_element.gherkin_statement)
        else
          raise "Bad type: #{feature_element.class}"
        end
      end

      def before_step(step)
        @gf.step(step.gherkin_statement)
        if @print_empty_match
          if(@outline)
            match = Gherkin::Formatter::Model::Match.new(step.gherkin_statement.outline_args, nil)
          else
            match = Gherkin::Formatter::Model::Match.new([], nil)
          end
          @gf.match(match)
        end
        @step_time = Time.now
      end

      def before_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background, file_colon_line)
        arguments = step_match.step_arguments.map{|a| Gherkin::Formatter::Argument.new(a.offset, a.val)}
        location = step_match.file_colon_line
        match = Gherkin::Formatter::Model::Match.new(arguments, location)
        if @print_empty_match
          # Trick the formatter to believe that's what was printed previously so we get arg highlights on #result
          @gf.instance_variable_set('@match', match)
        else
          @gf.match(match)
        end

        error_message = exception ? "#{exception.message} (#{exception.class})\n#{exception.backtrace.join("\n")}" : nil
        unless @outline
          @gf.result(Gherkin::Formatter::Model::Result.new(status, nil, error_message))
        end
      end

      def before_examples(examples)
        @gf.examples(examples.gherkin_statement)
      end

      #used for capturing duration
      def after_step(step)
        step_finish = (Time.now - @step_time)
        @gf.append_duration(step_finish)
      end

      def after_feature(feature)
        @gf.eof
      end

      def after_features(features)
        @gf.done
      end

      def embed(file, mime_type, label)
        data = File.open(file, 'rb') { |f| f.read }
        if defined?(JRUBY_VERSION)
          data = data.to_java_bytes
        end
        @gf.embedding(mime_type, data)
      end
    end
  end
end
