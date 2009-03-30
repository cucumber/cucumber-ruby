require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Ast
    describe StepCollection do
      it "should convert And to Given in snippets" do
        c = StepCollection.new([
          Step.new(1, 'Given', 'cukes'),
          Step.new(2, 'And', 'turnips')
        ])
        actual_keywords = c.step_invocations.map{|i| i.actual_keyword}
        actual_keywords.should == %w{Given Given}
      end
    end
  end
end
