require 'cucumber/pretty_printer'

module Cucumber
  class ProgressFormatter
    def initialize(io)
      @io = io
      @errors = []
    end

    def visit_stories(stories)
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
      scenario.accept(self)
    end
    
    def visit_step(step)
      case(step.error)
      when Pending
        @io.write('P')
      when NilClass
        @io.write('.')
      else
        @errors << step.error
        @io.write('F')
      end
    end
    
    def dump
      @io.puts
      @errors.each_with_index do |error,n|
        @io.puts
        @io.puts "#{n+1})"
        @io.puts error.message
        @io.puts error.backtrace.join("\n")
      end
    end
  end
end