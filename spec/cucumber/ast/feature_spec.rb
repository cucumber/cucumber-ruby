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
          [:scenario, "Scenario:", 
            "A Scenario", 
            [:comment, "    # My scenario comment  \n# On two lines \n"], 
            [:tag, "three"], 
            [:tag, "four"], 
            [:step, "Given", "a passing step with an inline arg:",
              [:table, 
                [:row, 
                  [:cell, "1"], [:cell, "22"], [:cell, "333"]], 
                [:row, 
                  [:cell, "4444"], [:cell, "55555"], [:cell, "666666"]]]], 
            [:step, "Given", "a happy step with an inline arg:", 
              [:pystring, "I like\nCucumber sandwich\n"]], 
            [:step, "Given", "a failing step"]]]
      end

      it "should only visit scenarios that match line number" do
        s1 = mock("Scenario 1")
        s2 = mock("Scenario 2")
        s3 = mock("Scenario 3")
        f = Ast::Feature.new(
          Ast::Comment.new(""),
          Ast::Tags.new([]),
          "My feature",
          [s1, s2, s3]
        )

        f.line = 33

        s1.should_receive(:at_line?).and_return(false)
        s2.should_receive(:at_line?).and_return(true)
        s3.should_receive(:at_line?).and_return(false)

        s2.should_receive(:accept)

        visitor = Visitor.new(nil)
        visitor.visit_feature(f)
      end
    end
  end
end
