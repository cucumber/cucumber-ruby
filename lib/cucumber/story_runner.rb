module Cucumber
  class Pending < StandardError
  end

  class ArgCountError < StandardError
  end

  class StoryRunner
    module CallIn
      attr_accessor :name
      
      def call_in(obj, *args)
        obj.extend(mod)
        raise ArgCountError.new("The #{name} block takes #{arity2} arguments, but there are #{args.length} matched variables") if args.length != arity2
        obj.__send__(meth, *args)
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

    PENDING = Proc.new{||}
    PENDING.extend(CallIn)
    PENDING.name = "PENDING"
    
    def initialize(formatter=nil)
      @formatter = formatter
      @parser = Parser::StoryParser.new
      @procs = {}
      @stories = []
    end

    def load(*files)
      files.each do |file|
        story = @parser.parse(IO.read(file))
        story.file = file
        @stories << story
      end
    end
  
    def run
      eval(@formatter, :loaded)
      eval(self, :executed)
      @formatter.dump
    end
    
    def eval(listener, phase)
      @stories.each do |story|
        @file = story.file
        story.eval(listener, phase)
      end
    end
    
    def story_executed(name)
      @formatter.story_executed(name) if @formatter.respond_to?(:story_executed)
    end
  
    def narrative_executed(name)
      @formatter.narrative_executed(name) if @formatter.respond_to?(:narrative_executed)
    end
  
    def scenario_executed(name, context=Object.new)
      @context = context
      @formatter.scenario_executed(name) if @formatter.respond_to?(:scenario_executed)
    end
  
    def step_executed(step_type, name, line, step)
      proc, args = find_proc(name)
      begin
        proc.call_in(@context, *args)
        @formatter.step_executed(step_type, name, line, step)
      rescue ArgCountError => e
        e.backtrace[0] = proc.backtrace_line
        strip_pos = e.backtrace.index("#{__FILE__}:#{__LINE__-4}:in `step_executed'")
        report_error(proc, strip_pos, step_type, name, line, step, e)
      rescue => e
        strip_pos = e.backtrace.index("#{__FILE__}:#{__LINE__-7}:in `step_executed'") - 2
        report_error(proc, strip_pos, step_type, name, line, step, e)
      end
    end
    
    def report_error(proc, strip_pos, step_type, name, line, step, e)
      # Remove lines underneath the plain text step
      e.backtrace[strip_pos..-1] = nil
      e.backtrace.flatten
      # Replace the step line with something more readable
      e.backtrace.replace(e.backtrace.map{|l| l.gsub(/`#{proc.meth}'/, "`#{step_type} #{proc.name}'")})
      e.backtrace << "#{@file}:#{line}:in `#{step_type} #{name}'"
      @formatter.step_executed(step_type, name, line, step, e)
    end
    
    def find_proc(name)
      args = nil
      regexp_proc_arr = @procs.select do |regexp, _| # TODO: Fix for Ruby 1.9
        if name =~ regexp
          args = $~.captures 
        end
      end
      raise "Too many" if regexp_proc_arr.length > 1
      regexp_proc = regexp_proc_arr[0]
      regexp_proc.nil? ? [PENDING, []] : [regexp_proc[1], args]
    end
    
    def register_proc(key, &proc)
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
      @procs[regexp] = proc
    end
  end
end
