require File.dirname(__FILE__) + '/../../spec_helper'
require 'treetop'
require 'cucumber/parser'

module Cucumber
  module Parser
    describe Feature do
      before do
        @parser = FeatureParser.new
      end
      
      def parse(text)
        @parser.parse_or_fail(text)
      end
      
      def parse_file(file)
        @parser.parse_file(File.dirname(__FILE__) + "/../treetop_parser/" + file)
      end

      describe "Comments" do
        it "should parse a file with only a one line comment" do
          parse("# My comment").comment.should == "# My comment"
        end

        it "should parse a file with only a multiline comment" do
          parse("# Hello\n# World").comment.should == "# Hello\n# World"
        end

        it "should parse a file with only a multiline comment with newlines" do
          pending do
            parse("# Hello\n\n# World\n").comment.should == "# Hello\n# World"
          end
        end
      end
    end
  end
end