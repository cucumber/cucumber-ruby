module Cucumber
  class Pending < StandardError
  end

  class StoryRunner
    module Named
      attr_accessor :name
    end
    
    PENDING = lambda{}
    PENDING.extend(Named)
    
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
      method = proc == PENDING ? "__cucumber_pending" : "__cucumber_#{proc.object_id}".to_sym
      begin
        mod = Module.new do
          define_method(method, &proc)
        end
        @context.extend(mod)
        @context.__send__(method, *args)
        @formatter.step_executed(step_type, name, line, step)
      rescue => e
        send_pos = e.backtrace.index("#{__FILE__}:#{__LINE__-3}:in `__send__'")
        # Remove lines underneath the plain text step
        e.backtrace[send_pos..-1] = nil if send_pos
        e.backtrace.flatten
        # Replace the step line with something more readable
        e.backtrace.replace(e.backtrace.map{|l| l.gsub(/`#{method}'/, "`#{step_type} /#{proc.name}/'")})
        e.backtrace << "#{@file}:#{line}:in `#{step_type} #{name}'"
        @formatter.step_executed(step_type, name, line, step, e)
      end
    end
    
    def find_proc(name)
      captures = nil
      procs = @procs.select do |regexp, proc|
        if name =~ regexp
          $~.captures 
        end
      end
      raise "Too many" if procs.length > 1
      pair = procs[0]
      pair.nil? ? [PENDING, []] : [pair[1], captures]
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
      proc.extend(Named)
      proc.name = regexp.source
      @procs[regexp] = proc
    end
  end
end
