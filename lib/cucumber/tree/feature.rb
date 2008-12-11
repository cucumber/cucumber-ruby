module Cucumber
  module Tree
    class Feature
      attr_reader :header
      attr_reader :scenarios
      MIN_PADDING = 2

      attr_accessor :file

      def initialize(header, &proc)
        @header = header
        @scenarios = []
        instance_eval(&proc) if block_given?
      end

      def add_scenario(name, line, &proc)
        scenario = Scenario.new(self, name, line, &proc)
        @scenarios << scenario
        scenario
      end

      def add_scenario_outline(name, line, &proc)
        scenario = ScenarioOutline.new(self, name, line, &proc)
        @scenarios << scenario
        scenario
      end

      def add_row_scenario(template_scenario, values, line)
        scenario = RowScenario.new(self, template_scenario, values, line)
        @scenarios << scenario
        scenario
      end
            
      def add_row_scenario_outline(template_scenario, values, line)
        scenario = RowScenarioOutline.new(self, template_scenario, values, line)
        @scenarios << scenario
        scenario
      end

      def scenario_named(name)
        @scenarios.find {|s| s.name == name}
      end

      def padding_length
        MIN_PADDING
      end

      def Scenario(name, &proc)
        line = caller[0] =~ /:(\d+)$/ ? $1 : nil
        add_scenario(name, line, &proc)
      end

      def ScenarioOutline(name, &proc)
        line = caller[0] =~ /:(\d+)$/ ? $1 : nil
        add_scenario_outline(name, line, &proc)
      end

      def Table(matrix = [], &proc)
        table = Table.new(matrix)
        proc.call(table)
  
        template_scenario = @scenarios.last
        template_scenario.table_header = matrix[0]

        matrix[1..-1].each do |row|
          if template_scenario.outline?
            add_row_scenario_outline(template_scenario, row, row.line)
          else
            add_row_scenario(template_scenario, row, row.line)
          end
        end
      end

      def accept(visitor)
        visitor.visit_header(@header)
        @scenarios.each do |scenario|
          if scenario.outline? && !scenario.row?
            visitor.visit_scenario_outline(scenario)
          elsif scenario.row?
            visitor.visit_row_scenario(scenario)
          else
            visitor.visit_regular_scenario(scenario)
          end
        end
      end
      
    end
  end
end
