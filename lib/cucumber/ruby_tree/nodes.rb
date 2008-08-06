require 'cucumber/tree'

module Cucumber
  module RubyTree
    class RubyFeature
      include Tree::Story

      def initialize(header, &proc)
        @header = header
        @scenarios = []
        instance_eval(&proc) if block_given?
      end

      def add_scenario(scenario)
        @scenarios << scenario
      end

      def Scenario(name, &proc)
        add_scenario RubyScenario.new(name, &proc)
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

      attr_reader :header, :scenarios

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
          RowStep.new(template_step.keyword, template_step.file, 999, template_step.proc, args)
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
        instance_eval(&proc) if block_given?
      end

      def add_step(keyword, name)
        @steps << RubyStep.new(keyword, name)
      end

      def Given(name)
        add_step('Given', name)
      end

      def When(name)
        add_step('When', name)
      end

      def Then(name)
        add_step('Then', name)
      end

      def And(name)
        add_step('And', name)
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
        @args = []
      end

      def gzub(format=nil, &proc)
        name.gzub(regexp, format, &proc)
      end

      attr_reader :keyword, :name, :file, :line
    end
  end
  
  class RowStep
    include Tree::Step
    
    attr_reader :keyword, :file, :line

    def initialize(keyword, file, line, proc, args)
      @keyword, @file, @line, @proc, @args = keyword, file, line, proc, args
    end
    
    def gzub(format=nil, &proc)
      raise "WWW"
    end

    def row?
      true
    end
  end
end

