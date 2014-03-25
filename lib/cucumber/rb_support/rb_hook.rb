module Cucumber
  module RbSupport
    # Wrapper for Before, After and AfterStep hooks
    class RbHook

      attr_reader :tag_expressions

      def initialize(rb_language, tag_expressions, proc)
        @rb_language = rb_language
        @tag_expressions = tag_expressions
        @proc = proc
      end

      def build_invoker(hook_type, argument, &block)
        LocatedProc.new(@proc.source_location) do
          invoke_in_world(hook_type, argument, &block)
        end
      end

      private

      def invoke_in_world(hook_type, argument, &block)
        @rb_language.current_world.cucumber_instance_exec(false, hook_type, *[argument, block].compact, &@proc)
      end

      class LocatedProc < Proc

        attr_reader :source_location

        def initialize(source_location, &block)
          @source_location = source_location
          super &block
        end
      end
    end
  end
end
