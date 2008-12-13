require File.dirname(__FILE__) + '/../../spec_helper'
require 'treetop'
require 'cucumber/parser/table'

module Cucumber
  module Parser
    describe Table do
      before do
        @parser = TableParser.new
      end
      
      def parse(text)
        @parser.parse(text) || raise(@parser.failure_reason)
      end

      it "should parse a row with one cell" do
        parse("hi").build.should == %w{hi}
      end

      it "should parse a row with two cells" do
        parse("hello|my|friend").build.should == %w{hello my friend}
      end

    end
  end
end