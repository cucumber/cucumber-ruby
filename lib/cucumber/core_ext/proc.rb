module Cucumber
  class ArityMismatchError < StandardError
  end

  module CoreExt
    # Proc extension that allows a proc to be called in the context of any object.
    # Also makes it possible to tack a name onto a Proc.
    module CallIn
      attr_accessor :name
      
      def call_in(obj, *args)
        obj.extend(mod)
        a = arity == -1 ? 0 : arity
        if self != StepMother::PENDING && args.length != a
          # We have to manually raise when the block has arity -1 (no pipes)
          raise ArityMismatchError.new("expected #{arity == -1 ? 0 : arity} block argument(s), got #{args.length}")
        else
          obj.__send__(meth, *args)
        end
      end

      def arity2
        arity == -1 ? 0 : arity
      end

      def backtrace_line
        to_s.match(/[\d\w]+@(.*)>/)[1] + ":in `#{name}'"
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