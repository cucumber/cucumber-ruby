require 'cucumber/hook_methods'

module Cucumber
  module RbSupport
    class RbHook
      include HookMethods

      attr_reader :tag_names
      
      def initialize(rb_language, tag_names, proc)
        @rb_language = rb_language
        @tag_names = tag_names.map{|tag| Ast::Tags.strip_prefix(tag)}
        @proc = proc
      end

      def invoke(args)
        @rb_language.current_world.cucumber_instance_exec(false, *args, &@proc)
      end
    end
  end
end