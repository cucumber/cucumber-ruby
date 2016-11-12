# frozen_string_literal: true
module Cucumber
  module RbSupport
    # A Ruby Transform holds a Regexp and a Proc, and is created
    # by calling <tt>Transform in the <tt>support</tt> ruby files.
    # See also RbDsl.
    #
    # Example:
    #
    #   Transform /^(\d+) cucumbers$/ do |cucumbers_string|
    #     cucumbers_string.to_i
    #   end
    #
    class RbTransform
      class MissingProc < StandardError
        def message
          'Transforms must always have a proc with at least one argument'
        end
      end

      def initialize(rb_language, pattern, proc)
        raise MissingProc if proc.nil? || proc.arity < 1
        @rb_language = rb_language
        @regexp = Regexp.new(pattern)
        @proc = proc
      end

      def match(arg)
        arg ? arg.match(@regexp) : nil
      end

      def invoke(arg)
        return unless matched = match(arg)
        args = matched.captures.empty? ? [arg] : matched.captures
        @rb_language.current_world.cucumber_instance_exec(true, @regexp.inspect, *args, &@proc)
      end

      def to_s
         convert_captures(strip_anchors(@regexp.source))
      end

      private
      def convert_captures(regexp_source)
        regexp_source
          .gsub(/(\()(?!\?[<:=!])/,'(?:')
          .gsub(/(\(\?<)(?![=!])/,'(?:<')
      end

      def strip_captures(regexp_source)
        regexp_source.
          gsub(/(\()/, '').
          gsub(/(\))/, '')
      end

      def strip_anchors(regexp_source)
        regexp_source.
          gsub(/(^\^|\$$)/, '')
      end
    end
  end
end
