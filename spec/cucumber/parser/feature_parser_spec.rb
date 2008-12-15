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
          parse("# My comment\nFeature: hi\n").comment.value.should == "# My comment\n"
        end

        it "should parse a file with only a multiline comment" do
          parse("# Hello\n# World\nFeature: hi\n").comment.value.should == "# Hello\n# World\n"
        end

        it "should parse a file with no comments" do
          parse("Feature: hi\n").comment.value.should == ""
        end

        it "should parse a file with only a multiline comment with newlines" do
          pending do
            parse("# Hello\n\n# World\n").comment.should == "# Hello\n# World"
          end
        end
      end

      describe "Tags" do
        it "should parse a file with tags on a feature" do
          parse("# My comment\n@hello @world Feature: hi\n").tags.map{|tag| tag.name}.should == %w{hello world}
        end
      end

      describe "Scenarios" do
        it "should parse an empty scenario" do
          parse("Feature: Hi\nScenario: Hello\n").feature_elements[0].name.should == "Hello"
        end
      end
    end
  end
end