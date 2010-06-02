require "json"
require "cucumber/formatter/io"

module Cucumber
  module Formatter
    # The formatter used for <tt>--format json</tt>
    class Json
      include Io

      def initialize(step_mother, io, options)
        @io      = ensure_io(io, "json")
        @options = options
      end

      def before_features(features)
        @json = {:features => []}
      end

      def before_feature(feature)
        @current_object = {:file => feature.file, :name => feature.name}
        @json[:features] << @current_object
      end

      def before_tags(tags)
        @current_object[:tags] = tags.tag_names
      end

      def before_feature_element(feature_element)
        elements = @current_object[:elements] ||= []

        # change current object to the feature_element
        @current_object = {}
        elements << @current_object
      end

      def scenario_name(keyword, name, file_colon_line, source_indent)
        @current_object[:name] = name
        @current_object[:file_colon_line] = file_colon_line
      end

      def before_steps(steps)
        @current_object[:steps] = []
      end

      def before_step(step)
        @current_step = {}
        @current_object[:steps] << @current_step
      end

      def before_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        if exception
          @current_step[:exception] = {
            :class     => exception.class.name,
            :message   => exception.message,
            :backtrace => exception.backtrace
          }
        end
      end

      def step_name(keyword, step_match, status, source_indent, background)
        @current_step[:status]          = status
        @current_step[:name]            = "#{keyword}#{step_match.name || step_match.format_args}" # ?
        @current_step[:file_colon_line] = step_match.file_colon_line
      end

      def after_step(step)
        @current_step = nil
      end

      def after_feature_element(feature_element)
        # change current object back to the last feature
        @current_object = @json[:features].last
      end

      def after_features(features)
        @io.write json_string
        @io.flush
      end

      def json_string
        @json.to_json
      end

    end # Json
  end # Formatter
end # Cucumber
