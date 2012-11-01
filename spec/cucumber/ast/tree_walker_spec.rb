require 'spec_helper'

module Cucumber::Ast
  describe TreeWalker do
    it "should visit features" do
      tw = TreeWalker.new(nil, [mock('listener', :before_visit_features => nil)])
      tw.should_not_receive(:warn)
      tw.visit_features(mock('features', :accept => nil))
    end
    it "should visit features return [] when listeners is []" do
      tw = TreeWalker.new(nil)
      tw.step_mother.should == nil
      tw.should_not_receive(:warn)
      tw.visit_features(mock('features', :accept => nil)).should == []
    end
  end
end
