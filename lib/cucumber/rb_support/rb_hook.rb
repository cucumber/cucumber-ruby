module Cucumber
  module RbSupport
    # Wrapper for Before, After and AfterStep hooks
    class RbHook
      attr_reader :tag_names
      
      def initialize(rb_language, tag_names, proc)
        @rb_language = rb_language
        @tag_names = tag_names
        @proc = proc
      end

      def invoke(location, scenario)
        @rb_language.current_world.cucumber_instance_exec(false, location, scenario, &@proc)
      end
    end
  end
end