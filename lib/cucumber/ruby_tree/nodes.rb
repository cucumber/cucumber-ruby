require 'cucumber/tree'

module Cucumber
  module RubyTree
    class RubyStory
      include Tree::Story

      def initialize(header, narrative, &proc)
        @header, @narrative = header, narrative
        @scenarios = []
        instance_eval(&proc)
      end

      def Scenario(name, &proc)
        @scenarios << RubyScenario.new(name, &proc)
      end
      
      def Table(matrix = [], &proc)
        table = RubyTable.new(matrix)
        proc.call(table)
        last_scenario = @scenarios.last
        matrix[1..-1].each do |row|
          @scenarios << RowScenario.new(last_scenario, row)
        end
      end

    protected

      attr_reader :header, :narrative, :scenarios

    end
    
    class RubyTable
      def initialize(rows)
        @rows = rows
      end
      
      def |(cell)
        @row ||= []
        if cell == self
          @rows << @row
          @row = nil
        else
          @row << cell.to_s
        end
        self
      end
    end

    class RowScenario
      include Tree::Scenario
      
      def row?
        true
      end

      def initialize(template_scenario, values)
        @template_scenario, @values = template_scenario, values
      end
      
      def steps
        @steps ||= @template_scenario.steps.map do |template_step|
          args = template_step.args.map do
            @values.shift
          end
          RowStep.new(template_step.proc, args)
        end
      end
    end

    class RubyScenario
      include Tree::Scenario
      
      def row?
        false
      end

      def initialize(name, &proc)
        @name = name
        @steps = []
        @line = *caller[2].split(':')[1].to_i
        instance_eval(&proc)
      end

      def Given(name)
        @steps << RubyStep.new('Given', name)
      end

      def When(name)
        @steps << RubyStep.new('When', name)
      end

      def Then(name)
        @steps << RubyStep.new('Then', name)
      end

      def And(name)
        @steps << RubyStep.new('And', name)
      end

      attr_reader :name, :steps, :line

    end

    class RubyStep
      include Tree::Step
      attr_accessor :error
    
      def row?
        false
      end

      def initialize(keyword, name)
        @keyword, @name = keyword, name
        @file, @line, _ = *caller[2].split(':')
      end

      attr_reader :keyword, :name, :file, :line
    end
  end
  
  class RowStep
    include Tree::Step
    
    def row?
      true
    end

    def initialize(proc, args)
      @proc, @args = proc, args
    end
    
    def name
      args.inspect
    end
  end
end

