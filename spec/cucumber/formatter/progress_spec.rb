require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/formatter/progress'

module Cucumber
  module Formatter
    describe Progress do

      before(:each) do
        Term::ANSIColor.coloring = false
        @out = StringIO.new
        progress = Progress.new(mock("step mother"), @out, {})
        @visitor = Ast::TreeWalker.new(nil, [progress])
      end
 
      describe "visiting a table cell value without a status" do
        it "should take the status from the last run step" do
          @visitor.visit_step_result('', '', nil, :failed, nil, 10, nil)
          @visitor.visit_table_cell_value('value', nil)

          @out.string.should == "F"
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
