require 'spec_helper'
require 'cucumber/formatter/progress'

module Cucumber
  module Formatter
    describe Progress do

      before(:each) do
        Cucumber::Term::ANSIColor.coloring = false
        @out = StringIO.new
        progress = Cucumber::Formatter::Progress.new(double("Runtime"), @out, {})
        @visitor = Cucumber::Ast::TreeWalker.new(nil, [progress])
      end

      describe "visiting a table cell value without a status" do
        # TODO: this seems bizarre. Why not just mark the cell as skipped or noop?
        it "should take the status from the last run step" do
          @visitor.visit_step_result('', '', nil, :failed, nil, 10, nil, nil)
          @visitor.visit_outline_table(double) do
            @visitor.visit_table_cell_value('value', nil)
          end
          @out.string.should == "FF"
        end
      end

      describe "visiting a table cell which is a table header" do
        it "should not output anything" do
          @visitor.visit_table_cell_value('value', :skipped_param)
          @out.string.should == ""
        end
      end

    end
  end
end
