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

      def add_scenario(name)
        raise "Pass a string: #{name.inspect}" unless String === name
        scenario = RubyScenario.new(self, name)
        @scenarios << scenario
        scenario
      end
      
      def add_row_scenario(template_scenario, values, line)
        scenario = RowScenario.new(self, template_scenario, values, line)
        @scenarios << scenario
        scenario
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
      
      attr_reader :line
      
      def row?
        true
      end

      def file
        @feature.file
      end

      def initialize(feature, template_scenario, values, line)
        @feature, @template_scenario, @values, @line = feature, template_scenario, values, line
      end
      
      def steps
        @steps ||= @template_scenario.steps.map do |template_step|
          args = template_step.args.map do
            @values.shift
          end
          RowStep.new(self, template_step.keyword, template_step.proc, args)
        end
      end
    end

    class RubyScenario
      include Tree::Scenario
      
      # If a table follows, the header will be stored here. Weird, but convenient.
      attr_accessor :table_header
      
      def row?
        false
      end
      
      def file
        @feature.file
      end

      def initialize(feature, name, &proc)
        @feature, @name = feature, name
        @steps = []
        @line = *caller[2].split(':')[1].to_i
        instance_eval(&proc) if block_given?
      end

      def add_step(keyword, name, line)
        @steps << RubyStep.new(self, keyword, name, line)
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

      def initialize(scenario, keyword, name, line)
        @scenario, @keyword, @name, @line = scenario, keyword, name, line
#        @file, @line, _ = *caller[2].split(':')
        @args = []
      end

      def gzub(format=nil, &proc)
        name.gzub(regexp, format, &proc)
      end

      attr_reader :keyword, :name, :line
    end
  end
  
  class RowStep
    include Tree::Step
    
    attr_reader :keyword

    def initialize(scenario, keyword, proc, args)
      @scenario, @keyword, @proc, @args = scenario, keyword, proc, args
    end
    
    def gzub(format=nil, &proc)
      raise "WWW"
    end

    def row?
      true
    end
    
    def line
      @scenario.line
    end
  end
end

