require 'spec_helper'

module Cucumber::Ast
  describe TreeWalker do
    let(:tree_walker) do
      TreeWalker.new(nil, [mock('listener', :before_visit_features => nil)])
    end
    let(:features) { mock('features', :accept => nil) }

    it "should visit features" do
      tree_walker.should_not_receive(:warn)
      tree_walker.visit_features(features)
    end

    it "should return self" do
      tree_walker.visit_features(features).should == tree_walker
    end
  end
end
