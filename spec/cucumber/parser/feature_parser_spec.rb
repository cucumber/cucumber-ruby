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
        feature = @parser.parse_or_fail(text)
        feature.extend(Module.new{
          attr_reader :comment, :tags, :name, :feature_elements
        })
      end

      def parse_file(file)
        @parser.parse_file(File.dirname(__FILE__) + "/../treetop_parser/" + file)
      end

      describe "Header" do
        it "should parse Feature with blurb" do
          parse("Feature: hi\nwith blurb\n")
        end
      end

      describe "Comments" do
        it "should parse a file with only a one line comment" do
          parse("# My comment\nFeature: hi\n").to_sexp.should ==
          [:feature, "hi",
            [:comment, "# My comment\n"]]
        end

        it "should parse a file with only a multiline comment" do
          parse("# Hello\n# World\nFeature: hi\n").to_sexp.should ==
          [:feature, "hi",
            [:comment, "# Hello\n# World\n"]]
        end

        it "should parse a file with no comments" do
          parse("Feature: hi\n").to_sexp.should ==
          [:feature, "hi"]
        end

        it "should parse a file with only a multiline comment with newlines" do
          pending do
            parse("# Hello\n\n# World\n").comment.should == "# Hello\n# World"
          end
        end
      end

      describe "Tags" do
        it "should parse a file with tags on a feature" do
          parse("# My comment\n@hello @world Feature: hi\n").to_sexp.should ==
          [:feature, "hi",
            [:comment, "# My comment\n"],
            [:tag, "hello"],
            [:tag, "world"]]
        end
      end

      describe "Scenarios" do
        it "can be empty" do
          parse("Feature: Hi\nScenario: Hello\n").to_sexp.should ==
          [:feature, "Hi",
            [:scenario, "Scenario:", "Hello"]]
        end

        it "should have steps" do
          parse("Feature: Hi\nScenario: Hello\nGiven I am a step\n").to_sexp.should ==
          [:feature, "Hi",
            [:scenario, "Scenario:", "Hello",
              [:step, "Given", "I am a step"]]]
        end

        it "should have steps with inline table" do
          parse("Feature: Hi\nScenario: Hello\nGiven I have a table\n|1|2|\n").to_sexp.should ==
          [:feature, "Hi",
            [:scenario, "Scenario:", "Hello",
              [:step, "Given", "I have a table",
                [:table,
                  [:row,
                    [:cell, "1"],
                    [:cell, "2"]]]]]]
        end
      end

      describe "Scenario Outlines" do
        it "can be empty" do
          parse("Feature: Hi\nScenario Outline: Hello\nExamples:\n|1|2|\n").to_sexp.should ==
          [:feature, "Hi",
            [:scenario_outline, "Scenario Outline:", "Hello",
              [:examples, "Examples:", "",
                [:table,
                  [:row,
                    [:cell, "1"],
                    [:cell, "2"]]]]]]
        end

        it "should have steps with inline table" do
          parse("Feature: Hi\nScenario Outline: Hello\nGiven I have a table\n|1|2|\n").to_sexp.should ==
          [:feature, "Hi",
            [:scenario_outline, "Scenario Outline:", "Hello",
              [:step, "Given", "I have a table",
                [:table,
                  [:row,
                    [:cell, "1"],
                    [:cell, "2"]]]]]]
        end

        it "should have examples" do
          parse("Feature: Hi\nScenario Outline: Hello\nGiven I have a table\n|1|2|\nExamples:\n|x|y|\n|5|6|").to_sexp.should ==
          [:feature, "Hi",
            [:scenario_outline, "Scenario Outline:", "Hello",
              [:step, "Given", "I have a table",
                [:table,
                  [:row,
                    [:cell, "1"],
                    [:cell, "2"]]]],
              [:examples, "Examples:", "",
                [:table,
                  [:row,
                    [:cell, "x"],
                    [:cell, "y"]],
                  [:row,
                    [:cell, "5"],
                    [:cell, "6"]]]]]]
        end
      end

      describe "Syntax" do
        files = Dir["#{File.dirname(__FILE__)}/../treetop_parser/*.feature"].reject do |f|
          f =~ /given_scenario.feature/ || f =~ /fit_scenario.feature/
        end
        files.each do |f|
          it "should parse #{f}" do
            @parser.parse_or_fail(IO.read(f))
          end
        end
      end
    end
  end
end
