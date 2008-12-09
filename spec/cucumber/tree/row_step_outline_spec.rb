require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Tree
    describe RowStepOutline do
      
      def mock_step(stubs = {})
        mock("step", {:extra_args => []}.merge(stubs))
      end
      
      
      it "should be a outline" do
        outline_row = RowStepOutline.new(mock("scenario"), mock_step, 'outline', [], 1)
        
        outline_row.should be_a_outline
      end

      it "should be a row step" do
        outline_row = RowStepOutline.new(mock("scenario"), mock_step, 'outline', [], 1)
        
        outline_row.should be_a_row
      end

      it "should have visible args" do
        outline_row = RowStepOutline.new(mock("scenario"), mock_step, 'outline', ["tiger", "night"], 1)

        outline_row.visible_args.should == ["tiger", "night"]
      end
      
      it "should have extra args" do
        outline_row = RowStepOutline.new(mock("scenario"), mock_step(:extra_args => ["extra", "arrrgs"]), 'outline', [], 1)

        outline_row.extra_args.should == ["extra", "arrrgs"]
      end
      
    end
  end
end
