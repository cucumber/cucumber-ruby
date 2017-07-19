# frozen_string_literal: true
require 'cucumber/glue/invoke_in_world'

module Cucumber
  module Glue
    # A Ruby Transform holds a Regexp and a Proc, and is created
    # by calling <tt>Transform in the <tt>support</tt> ruby files.
    # See also Dsl.
    #
    # Example:
    #
    #   Transform /^(\d+) cucumbers$/ do |cucumbers_string|
    #     cucumbers_string.to_i
    #   end
    #
    class Transform
      class MissingProc < StandardError
        def message
          'Transforms must always have a proc with at least one argument'
        end
      end

      def initialize(registry, pattern, proc)
        raise MissingProc if proc.nil? || proc.arity < 1
        @registry, @regexp, @proc = registry, Regexp.new(pattern), proc
      end

      def match(arg)
        arg ? arg.match(@regexp) : nil
      end

      def invoke(arg)
        matched = match(arg)

        return unless matched
        args = matched.captures.empty? ? [arg] : matched.captures
        InvokeInWorld.cucumber_instance_exec_in(@registry.current_world, true, @regexp.inspect, *args, &@proc)
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
