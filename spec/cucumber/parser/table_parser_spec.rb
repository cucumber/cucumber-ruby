require File.dirname(__FILE__) + '/../../spec_helper'
require 'treetop'
require 'cucumber/parser'

module Cucumber
  module Parser
    describe 'Tables' do
      before do
        @parser = FeatureParser.new
      end
      
      def parse(text)
        @parser.__send__(:prepare_to_parse, text)
        @parser.root = :table
        table = @parser._nt_table
        table.raw
      end

      it "should parse a 1x2 table with newline" do
        parse(" | 1 | 2 | \n").should == [%w{1 2}]
      end

      it "should parse a 1x2 table without newline" do
        parse("| 1 | 2 |").should == [%w{1 2}]
      end

      it "should parse a 1x2 table without spaces" do
        parse("|1|2|").should == [%w{1 2}]
      end

      it "should parse a 2x2 table" do
        parse("| 1 | 2 |\n| 3 | 4 |\n").should == [%w{1 2}, %w{3 4}]
      end

      it "should parse a 2x2 table with several newlines" do
        parse("| 1 | 2 |\n| 3 | 4 |\n\n\n").should == [%w{1 2}, %w{3 4}]
      end

      it "should parse a 2x2 table with empty cells" do
        parse("| 1 |  |\n|| 4 |\n").should == [['1', nil], [nil, '4']]
      end

      it "should not parse a 2x2 table that isn't closed" do
        parse("| 1 |  |\n|| 4 ").should_not == [['1', nil], [nil, '4']]
      end
    end
  end
end