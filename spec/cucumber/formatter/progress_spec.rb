require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Formatter
    describe Progress do

      before(:all) do
        Term::ANSIColor.coloring = false
      end

      describe "visiting a table cell value without a status" do
       it "should default to the 'pass' status" do
         out = StringIO.new
         progress = Progress.new(mock("step mother"), out, {})

         progress.visit_table_cell_value('value', 10, nil)

         out.string.should == "."
       end
      end

    end
  end
end
