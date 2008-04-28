module Cucumber
  class Pending < StandardError
  end

  class StoryRunner
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
    end
    
    def eval(listener, phase)
      @stories.each do |story|
        @file = story.file
        story.eval(listener, phase)
      end
    end
    
    def story_executed(name)
      @formatter.story_executed(name)
    end
  
    def narrative_executed(name)
      @formatter.narrative_executed(name)
    end
  
    def scenario_executed(name)
      @context = Object.new
      @formatter.scenario_executed(name)
    end
  
    def step_executed(step_type, name, line)
      proc = find_proc(name)
      begin
        @context.instance_eval(&proc)
        @formatter.step_executed(step_type, name, line)
      rescue => e
        pos = e.backtrace.index("#{__FILE__}:#{__LINE__-3}:in `instance_eval'")
        e.backtrace[pos..-1] = nil if pos
        e.backtrace.flatten
        e.backtrace << "#{@file}:#{line}: in `#{step_type} #{name}'"
        @formatter.step_executed(step_type, name, line, e)
      end
    end
    
    def find_proc(name)
      @procs[name]
    end
    
    def register_proc(name, &proc)
      @procs[name] = proc
    end
  end
end
