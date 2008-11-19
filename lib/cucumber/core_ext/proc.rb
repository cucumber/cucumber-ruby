module Cucumber
  class ArityMismatchError < StandardError
  end

  module CoreExt
    # Proc extension that allows a proc to be called in the context of any object.
    # Also makes it possible to tack a name onto a Proc.
    module CallIn
      PROC_PATTERN = /[\d\w]+@(.*):(.*)>/
      
      if Proc.new{}.to_s =~ PROC_PATTERN
        def to_backtrace_line
          "#{file_colon_line}:in `#{name}'"
        end

        def to_comment_line
          "# #{file_colon_line}"
        end

        def file_colon_line
          path, line = *to_s.match(PROC_PATTERN)[1..2]
          path = File.expand_path(path)
          pwd = Dir.pwd
          path = path[pwd.length+1..-1]
          "#{path}:#{line}"
        end
      else
        # This Ruby implementation doesn't implement Proc#to_s correctly
        STDERR.puts "*** THIS RUBY IMPLEMENTATION DOESN'T REPORT FILE AND LINE FOR PROCS ***"
        
        def to_backtrace_line
          nil
        end

        def to_comment_line
          ""
        end
      end
      
      attr_accessor :name
      
      def call_in(obj, *args)
        obj.extend(mod)
        if self != StepMother::PENDING && args.length != arity2
          # We have to manually raise when the block has arity -1 (no pipes)
          raise ArityMismatchError.new("expected #{arity2} block argument(s), got #{args.length}")
        else
          obj.__send__(meth, *args)
        end
      end

      def arity2
        arity == -1 ? 0 : arity
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