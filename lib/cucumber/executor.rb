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
      @world_proc = lambda{ Object.new }
      @step_procs = {}
      @before_procs = []
      @after_procs = []
    end
    
    def register_world_proc(&proc)
      @world_proc = proc
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
        Regexp.new("^#{key}$")
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
      @formatter.dump
    end

    def visit_story(story)
      story.accept(self)
    end

    def visit_header(header)
      @formatter.header_executing(header) if @formatter.respond_to?(:header_executing)
    end

    def visit_narrative(narrative)
      @formatter.narrative_executing(narrative) if @formatter.respond_to?(:narrative_executing)
    end

    def visit_scenario(scenario)
      @error = nil
      @world = @world_proc.call
      @formatter.scenario_executing(scenario) if @formatter.respond_to?(:scenario_executing)
      @before_procs.each{|p| p.call_in(@world, *[])}
      scenario.accept(self)
      @after_procs.each{|p| p.call_in(@world, *[])}
    end

    def visit_step(step)
      proc, args = find_step_proc(step)
      if @error.nil?
        begin
          proc.call_in(@world, *args)
        rescue ArgCountError => e
          e.backtrace[0] = proc.backtrace_line
          strip_pos = e.backtrace.index("#{__FILE__}:#{__LINE__-3}:in `visit_step'")
          format_error(proc, strip_pos, step, e)
        rescue => e
          visit_step_line = "#{__FILE__}:#{__LINE__-6}:in `visit_step'"
          visit_step_pos = e.backtrace.index(visit_step_line)
          if visit_step_pos
            strip_pos = visit_step_pos - (Pending === e ? 3 : 2)
          else
            # This happens with rails, because they screw up the backtrace
            # before we get here (injecting erb stactrace and such)
      	  end
          format_error(proc, strip_pos, step, e)
        end
        @formatter.step_executed(step)
      else
        @formatter.step_skipped(step)
      end
    end

    def find_step_proc(step)
      args = nil
      regexp_proc_arr = @step_procs.select do |regexp, _|
        if step.name =~ regexp
          step.regexp = regexp
          args = $~.captures 
        end
      end
      if regexp_proc_arr.length > 1
        regexen = regexp_proc_arr.transpose[0].map{|re| re.inspect}.join("\n  ")
        raise "\"#{step.name}\" matches several steps:\n\n  #{regexen}\n\nPlease give your steps unambiguous names\n" 
      end
      regexp_proc = regexp_proc_arr[0]
      regexp_proc.nil? ? [PENDING, []] : [regexp_proc[1], args]
    end

    def format_error(proc, strip_pos, step, e)
      @error = e unless Pending === e
      # Remove lines underneath the plain text step
      e.backtrace[strip_pos..-1] = nil unless strip_pos.nil?
      e.backtrace.flatten
      # Replace the step line with something more readable
      e.backtrace.replace(e.backtrace.map{|l| l.gsub(/`#{proc.meth}'/, "`#{step.keyword} #{proc.name}'")})
      e.backtrace << "#{step.file}:#{step.line}:in `#{step.keyword} #{step.name}'"
      step.error = e
    end
    
  end
end