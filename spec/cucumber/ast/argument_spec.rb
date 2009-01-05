require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/ast'

module Cucumber
  module Ast
    describe Argument do
      
      it "should insert argument value into string" do
        argument = Argument.new('film', 'Vertigo')
        
        argument.replace_in('I want to watch <film>').should == "I want to watch Vertigo"
      end
      
    end
  end
end