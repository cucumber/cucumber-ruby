require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/ast/feature_factory'

module Cucumber
  module Ast
    describe Feature do
      include FeatureFactory

      it "should convert to sexp" do
        feature = create_feature(Object.new)
        feature.to_sexp.should == 
        [:feature, 
          "Pretty printing", 
          [:comment, "# My feature comment\n"], 
          [:tag, "one"], 
          [:tag, "two"], 
          [:background, 2, 'Background:',
            [:step, 3, "Given", "a passing step"],
            [:scenario, 9, "Scenario:", 
              "A Scenario", 
              [:comment, "    # My scenario comment  \n# On two lines \n"], 
              [:tag, "three"], 
              [:tag, "four"], 
              [:step_invocation, 10, "Given", "a passing step with an inline arg:",
                [:table, 
                  [:row, 
                    [:cell, "1"], [:cell, "22"], [:cell, "333"]], 
                  [:row, 
                    [:cell, "4444"], [:cell, "55555"], [:cell, "666666"]]]], 
              [:step_invocation, 11, "Given", "a happy step with an inline arg:", 
                [:py_string, "\n I like\nCucumber sandwich\n"]], 
              [:step_invocation, 12, "Given", "a failing step"]]]]
      end

      it "should only visit scenarios that match" do
        step_mother = Object.new
        step_mother.extend(StepMother)
        
        s1 = mock("Scenario 1").as_null_object
        s2 = mock("Scenario 2").as_null_object
        s3 = mock("Scenario 3").as_null_object
        [s1, s2, s3].each{|s| s.should_receive(:feature=)}
        f = Ast::Feature.new(
          Ast::Comment.new(""),
          Ast::Tags.new(22, []),
          "My feature",
          [s1, s2, s3]
        )
        features = mock('Features')
        f.features = features

        f.lines = [33]

        features.should_receive(:visit?).with(s1, [33]).and_return(false)
        features.should_receive(:visit?).with(s2, [33]).and_return(true)
        features.should_receive(:visit?).with(s3, [33]).and_return(false)

        s2.should_receive(:accept)

        visitor = Visitor.new(step_mother)
        visitor.visit_feature(f)
      end
    end
  end
end
