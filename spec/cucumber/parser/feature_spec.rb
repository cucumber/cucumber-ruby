require File.dirname(__FILE__) + '/../../spec_helper'
require 'treetop'
require 'cucumber/parser/basic'
require 'cucumber/parser/table'
require 'cucumber/parser/feature'
require 'cucumber/ast'

module Cucumber
  module Parser
    describe Feature do
      before do
        @parser = FeatureParser.new
      end
      
      def parse(text)
        tree = @parser.parse(text)
        raise(@parser.failure_reason) if tree.nil?
        tree.build
      end
      
      it "should parse a file with only comments" do
        parse("# My comment").comment.should == "# My comment"
        parse("# My other comment").comment.should == "# My other comment"
      end
    end
  end
end