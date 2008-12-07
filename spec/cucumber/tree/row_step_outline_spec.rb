require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Tree
    describe RowStepOutline do
      
      it "should be a outline" do
        outline_row = RowStepOutline.new(mock("scenario"), 'Given', 'outline', [], 1)
        
        outline_row.should be_a_outline
      end

      it "should be a row step" do
        outline_row = RowStepOutline.new(mock("scenario"), 'Given', 'outline', [], 1)
        
        outline_row.should be_a_row
      end

      it "should have visible args" do
        outline_row = RowStepOutline.new(mock("scenario"), 'Given', 'outline', ["tiger", "night"], 1)

        outline_row.visible_args.should == ["tiger", "night"]
      end
      
    end
  end
end
