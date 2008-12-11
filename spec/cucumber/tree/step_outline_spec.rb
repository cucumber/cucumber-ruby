require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Tree
    describe StepOutline do

      it "should be a outline" do
          step_outline = StepOutline.new(mock("scenario"), 'Given', 'outline', 1)

          step_outline.should be_a_outline
      end
      
    end
  end
end


