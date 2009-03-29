module Cucumber
  module Ast
    class OutlineTable < Table
      def initialize(raw, scenario_outline)
        super(raw)
        @scenario_outline = scenario_outline
        @cells_class = ExampleCells
        
        cells_rows.each do |cells|
          cells.create_step_invocations!(scenario_outline)
        end
      end

      def accept(visitor)
        cells_rows.each_with_index do |row, n|
          if n == 0 || matches?(visitor, row)
            visitor.visit_table_row(row)
          end
        end
        nil
      end

      def descend?(visitor)
        cells_rows.detect{|cells_row| cells_row.descend?(visitor)}
      end
      
      def matches?(visitor, cells)
        @scenario_outline.matches_tags_and_name?(visitor) &&
        (visitor.matches_lines?(cells) || visitor.matches_lines?(@scenario_outline))
      end
      
      def skip_invoke!
        cells_rows.each do |cells|
          cells.skip_invoke!
        end
      end

      class ExampleCells < Cells
        def create_step_invocations!(scenario_outline)
          @step_invocations = scenario_outline.step_invocations(self)
        end
        
        def descend?(visitor)
          @table.matches?(visitor, self)
        end

        def skip_invoke!
          @step_invocations.each do |step_invocation|
            step_invocation.skip_invoke!
          end
        end

        def accept(visitor)
          if header?
            @cells.each do |cell|
              cell.status = :skipped_param
              visitor.visit_table_cell(cell)
            end
          else
            visitor.step_mother.before_and_after(self) do
              @step_invocations.each do |step_invocation|
                step_invocation.invoke(visitor.step_mother, visitor.options)
                @exception ||= step_invocation.exception
              end

              @cells.each do |cell|
                visitor.visit_table_cell(cell)
              end
            end
          end
        end

        private

        def header?
          index == 0
        end
      end
    end
  end
end
