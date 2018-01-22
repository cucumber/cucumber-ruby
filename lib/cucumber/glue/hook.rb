# frozen_string_literal: true

require 'cucumber/glue/invoke_in_world'

module Cucumber
  module Glue
    # TODO: Kill pointless wrapper for Before, After and AfterStep hooks with fire
    class Hook
      attr_reader :tag_expressions, :location

      def initialize(registry, tag_expressions, proc)
        @registry = registry
        @tag_expressions = tag_expressions
        @proc = proc
        @location = Cucumber::Core::Ast::Location.from_source_location(*@proc.source_location)
        warn_for_old_style_tag_expressions(tag_expressions)
      end

      def invoke(pseudo_method, arguments, &block)
        check_arity = false
        InvokeInWorld.cucumber_instance_exec_in(
          @registry.current_world,
          check_arity,
          pseudo_method,
          *[arguments, block].flatten.compact,
          &@proc
        )
      end

      private

      def warn_for_old_style_tag_expressions(tag_expressions)
        tag_expressions.each do |tag_expression|
          if tag_expression.include?('~') && tag_expression != '~@no-clobber' # ~@no-clobber is used in aruba
            warn("Deprecated: Found tagged hook with '#{tag_expression}'. Support for '~@tag' will be removed from the next release of Cucumber. Please use 'not @tag' instead.")
          end
          if tag_expression.include?(',')
            warn("Deprecated: Found tagged hook with '#{tag_expression}'. Support for '@tag1,@tag2' will be removed from the next release of Cucumber. Please use '@tag or @tag2' instead.")
          end
        end
      end
    end
  end
end
