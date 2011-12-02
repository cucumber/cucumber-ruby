require 'spec_helper'

require "cucumber/ast/multiline_argument"



module Cucumber
  module Ast
  module MultilineArgument
    class << self
      include Gherkin::Rubify

      describe MultilineArgument  do 
        context "MultilineArgument#from" do 
          it "when argument is String" do 
            argument  = "hello"
            MultilineArgument.from(argument).should == "hello"
          end
          it "when argument is Array" do 
          end
        end
      end
    end
  end
  end
end




