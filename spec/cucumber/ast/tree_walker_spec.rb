require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber::Ast
  describe TreeWalker do
    describe "when one of the listeners implements the method #visit_features" do
      it "should issue a warning about that interface being deprecated" do
        tw = TreeWalker.new(nil, [mock('listener', :visit_features => nil)], {})
        tw.should_receive(:warn).with /no longer supported/
        tw.visit_features(mock('features', :accept => nil))
      end
    end
    it "should visit features" do
      tw = TreeWalker.new(nil, [mock('listener', :before_visit_features => nil)], {})
      tw.should_not_receive(:warn)
      tw.visit_features(mock('features', :accept => nil))
    end
  end
end