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
    end
  end
end
