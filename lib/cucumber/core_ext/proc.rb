module Cucumber
  module CoreExt
    # Proc extension that allows a proc to be called in the context of any object.
    # Also makes it possible to tack a name onto a Proc.
    module CallIn
      attr_accessor :name
      
      def call_in(obj, *args, &proc)
        obj.extend(mod)
#        raise ArgCountError.new("The #{name} block takes #{arity2} arguments, but there are #{args.length} matched variables") if args.length != arity2
        obj.__send__(meth, *args, &proc)
      end

      def arity2
        arity == -1 ? 0 : arity
      end
      
      def backtrace_line
        inspect.match(/[\d\w]+@(.*)>/)[1] + ":in `#{name}'"
      end
      
      def meth
        @meth ||= "__cucumber_#{object_id}"
      end

      def mod
        p = self
        m = meth
        @mod ||= Module.new do
          define_method(m, &p)
        end
      end
    end 
  end
end