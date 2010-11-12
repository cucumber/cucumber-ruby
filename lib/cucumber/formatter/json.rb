require 'cucumber/formatter/io'
require 'gherkin/formatter/json_formatter'
require 'gherkin/formatter/argument'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format json</tt>
    class Json
      class Error < StandardError
      end

      include Io

      def initialize(step_mother, io, options)
        @io = ensure_io(io, "json")
        @obj = {'features' => []}
        @gf = Gherkin::Formatter::JSONFormatter.new(nil)
      end

      def before_features(features)
      end

      def before_feature(feature)
        @gf.uri(feature.file)
        @gf.feature(feature.gherkin_statement)
      end

      def before_background(background)
        @gf.background(background.gherkin_statement)
      end

      def before_feature_element(feature_element)
        case(feature_element)
        when Ast::Scenario
          @gf.scenario(feature_element.gherkin_statement)
        when Ast::ScenarioOutline
          @gf.scenario_outline(feature_element.gherkin_statement)
        else
          raise "Bad type: #{feature_element.class}"
        end
      end

      def before_step(step)
        @gf.step(step.gherkin_statement)
      end

      def before_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        arguments = step_match.args.map{|a| Gherkin::Formatter::Argument.new(a.byte_offset, a.val)}
        location = step_match.step_definition.file_colon_line
        @gf.match(Gherkin::Formatter::Model::Match.new(arguments, location))

        error_message = exception ? "#{exception.message} (#{exception.class})\n#{exception.backtrace.join("\n")}" : nil
        @gf.result(Gherkin::Formatter::Model::Result.new(status, error_message))
      end

      def before_examples(examples)
        @gf.examples(examples.gherkin_statement)
      end

      def after_feature(feature)
        @gf.eof
        @obj['features'] << @gf.gherkin_object
      end

      def after_features(features)
        @io.write(@obj.to_json)
      end

      def embed(file, mime_type)
        @gf.embedding(mime_type, File.read(file))
      end
    end
  end
end

