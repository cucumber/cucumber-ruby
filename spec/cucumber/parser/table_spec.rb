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

      it "should parse a 1x2 table with newline" do
        parse(" | 1 | 2 | \n").build.should == [%w{1 2}]
      end

      it "should parse a 1x2 table without newline" do
        parse("| 1 | 2 |").build.should == [%w{1 2}]
      end

      it "should parse a 2x2 table" do
        parse("| 1 | 2 |\n| 3 | 4 |").build.should == [%w{1 2}, %w{3 4}]
      end

      it "should parse a 2x2 table with empty cells" do
        parse("| 1 |  |\n|| 4 |").build.should == [['1', nil], [nil, '4']]
      end

    end
  end
end