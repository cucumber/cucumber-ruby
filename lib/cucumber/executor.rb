module Cucumber
  class Pending < StandardError
  end

  class ArgCountError < StandardError
  end

  class Executor
    module CallIn
      attr_accessor :name
      
      def call_in(obj, *args, &proc)
        obj.extend(mod)
        raise ArgCountError.new("The #{name} block takes #{arity2} arguments, but there are #{args.length} matched variables") if args.length != arity2
        obj.__send__(meth, *args, &proc)
      end

      def arity2
        arity == -1 ? 0 : arity
      end
      
      def backtrace_line
        inspect.match(/\d+@(.*)>/)[1] + ":in `#{name}'"
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

    PENDING = Proc.new{|| raise Pending}
    PENDING.extend(CallIn)
    PENDING.name = "PENDING"

    def initialize(formatter)
      @formatter = formatter
      @step_procs = {}
      @before_procs = []
      @after_procs = []
    end
    
    def register_before_proc(&proc)
      proc.extend(CallIn)
      @before_procs << proc
    end

    def register_after_proc(&proc)
      proc.extend(CallIn)
      @after_procs << proc
    end

    def register_step_proc(key, &proc)
      regexp = case(key)
      when String
        Regexp.new(key)
      when Regexp
        key
      else
        raise "Step patterns must be Regexp or String, but was: #{key.inspect}"
      end
      proc.extend(CallIn)
      proc.name = key.inspect
      @step_procs[regexp] = proc
    end

    def visit_stories(stories)
      @formatter.visit_stories(stories) if @formatter.respond_to?(:visit_stories)
      stories.accept(self)
    end

    def visit_story(story)
      story.accept(self)
    end

    def visit_header(header)
    end

    def visit_narrative(narrative)
    end

    def visit_scenario(scenario)
      @context = Object.new
      @before_procs.each{|p| p.call_in(@context, *[])}
      scenario.accept(self)
      @after_procs.each{|p| p.call_in(@context, *[])}
      @formatter.dump
    end

    def visit_step(step)
      return if @error
      proc, args = find_step_proc(step.name)
      begin
        proc.call_in(@context, *args)
      rescue ArgCountError => e
        e.backtrace[0] = proc.backtrace_line
        strip_pos = e.backtrace.index("#{__FILE__}:#{__LINE__-3}:in `visit_step'")
        format_error(proc, strip_pos, step, e)
      rescue => e
        strip_pos = e.backtrace.index("#{__FILE__}:#{__LINE__-6}:in `visit_step'") - (Pending === e ? 3 : 2)
        format_error(proc, strip_pos, step, e)
      end
      @formatter.step_executed(step)
    end

    def find_step_proc(name)
      args = nil
      regexp_proc_arr = @step_procs.select do |regexp, _| # TODO: Fix for Ruby 1.9
        if name =~ regexp
          args = $~.captures 
        end
      end
      raise "Too many" if regexp_proc_arr.length > 1
      regexp_proc = regexp_proc_arr[0]
      regexp_proc.nil? ? [PENDING, []] : [regexp_proc[1], args]
    end

    def format_error(proc, strip_pos, step, e)
      @error = e unless Pending === e
      # Remove lines underneath the plain text step
      e.backtrace[strip_pos..-1] = nil
      e.backtrace.flatten
      # Replace the step line with something more readable
      e.backtrace.replace(e.backtrace.map{|l| l.gsub(/`#{proc.meth}'/, "`#{step.keyword} #{proc.name}'")})
      e.backtrace << "#{step.file}:#{step.line}:in `#{step.keyword} #{step.name}'"
      step.error = e
    end
    
  end
end