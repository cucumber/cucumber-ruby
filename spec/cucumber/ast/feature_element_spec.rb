require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/step_mother'
require 'cucumber/ast'

module Cucumber
  describe FeatureElement do
    include FeatureElement

    describe "with multiline names" do
      it "should select the longest line as the text length" do
        @keyword = "key"  
        @name = "short\nvery longer\ntiny"
        text_length.should == 11 + Ast::Step::INDENT
      end
      
      it "should add keyword to first lines length" do
        @keyword = "key"  
        @name = "short\nvery longer\ntiny"
        
        first_line_length.should == (@keyword.jlength) + (first_line_name_length = 5)
      end
    end
    
    describe "with empty name" do
      it "should only return the length of the keyword" do
        @name = ""
        @keyword = "key"
        
        text_length.should == 3
      end
    end
    
  end
end

