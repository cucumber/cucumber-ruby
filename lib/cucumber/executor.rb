require 'cucumber/core_ext/proc'

module Cucumber
  class Pending < StandardError
  end

  class Executor
    attr_reader :failed
    
    def line=(line)
      @line = line
    end

    def initialize(formatter, step_mother)
      @formatter = formatter
      @world_proc = lambda{ Object.new }
      @before_procs = []
      @after_procs = []
      @step_mother = step_mother
    end
    
    def register_world_proc(&proc)
      @world_proc = proc
    end

    def register_before_proc(&proc)
      proc.extend(CoreExt::CallIn)
      @before_procs << proc
    end

    def register_after_proc(&proc)
      proc.extend(CoreExt::CallIn)
      @after_procs << proc
    end

    def visit_stories(stories)
      raise "Line number can only be specified when there is 1 story. There were #{stories.length}." if @line && stories.length != 1
      @step_mother.visit_stories(stories)
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
      if @line.nil? || scenario.at_line?(@line)
        @error = nil
        @world = @world_proc.call
        @formatter.scenario_executing(scenario) if @formatter.respond_to?(:scenario_executing)
        @before_procs.each{|p| p.call_in(@world, *[])}
        scenario.accept(self)
        @after_procs.each{|p| p.call_in(@world, *[])}
      end
    end

    def visit_step(step)
      if @error.nil?
        begin
          step.execute_in(@world)
        rescue Pending => ignore
        rescue => e
          @failed = true
          @error = e
        end
        @formatter.step_executed(step)
      else
        @formatter.step_skipped(step)
      end
    end    
  end
end