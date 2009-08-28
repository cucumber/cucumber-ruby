require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/formatter/progress'

module Cucumber
  module Formatter
    describe Progress do

      before(:each) do
        Term::ANSIColor.coloring = false
        @out = StringIO.new
        @progress = Progress.new(mock("step mother"), @out, {})
      end
 
      describe "visiting a table cell value without a status" do
        it "should take the status from the last run step" do
          @progress.visit_step_result('', '', nil, :failed, nil, 10, nil)
          @progress.visit_table_cell_value('value', nil)

          @out.string.should == "FF"
        end
      end

      describe "visiting a table cell which is a table header" do
        it "should not output anything" do
          @progress.visit_table_cell_value('value', :skipped_param)

          @out.string.should == ""
        end
      end

    end
  end
end
