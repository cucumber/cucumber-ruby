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

      it "should parse a 1x2 table" do
        parse("|1|2|").build.should == [%w{1 2}]
      end

    end
  end
end