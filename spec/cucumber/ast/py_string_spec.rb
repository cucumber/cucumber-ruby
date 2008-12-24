require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/ast/py_string'

module Cucumber
  module Ast
    describe PyString do
      it "should handle unindented" do
        ps = PyString.new("4.1\n4.2\n")
        ps.to_s.should == "4.1\n4.2\n"
      end

      it "should handle indented" do
        ps = PyString.new("  4.1\n  4.2\n")
        ps.to_s.should == "4.1\n4.2\n"
      end
    end
  end
end