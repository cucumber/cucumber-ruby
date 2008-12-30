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
            [:comment, "# My feature comment\n"],
            [:tag, "one"],
            [:tag, "two"],
            [:name, "Pretty printing"],
            [:scenario,
              [:comment, "    # My scenario comment  \n# On two lines \n"],
              [:tag, "three"],
              [:tag, "four"],
              [:name, "A Scenario"]]]
      end
    end
  end
end
