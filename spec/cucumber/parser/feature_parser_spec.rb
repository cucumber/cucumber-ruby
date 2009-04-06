require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/parser'

module Cucumber
  module Parser
    describe Feature do
      before do
        @parser = FeatureParser.new
      end

      def parse(text)
        feature = @parser.parse_or_fail(text)
      end

      def parse_file(file)
        @parser.parse_file(File.dirname(__FILE__) + "/../treetop_parser/" + file)
      end

      def parse_example_file(file)
        @parser.parse_file(File.dirname(__FILE__) + "/../../../examples/" + file)
      end

      describe "Header" do
        it "should parse Feature with blurb" do
          parse(%{Feature: hi
with blurb
})
        end
      end

      describe "Comments" do
        it "should parse a file with only a one line comment" do
          parse(%{# My comment
Feature: hi
}).to_sexp.should ==
          [:feature, nil, "Feature: hi\n",
            [:comment, "# My comment\n"]]
        end
        
        it "should parse a comment within a scenario" do
          pending "Store comment in node and output it in pretty formatter"
          parse(%{Feature: Hi
  Scenario: Hello
    Given foo
    # When bar
    Then baz
}).to_sexp.should == 
          [:feature, nil, "Feature: Hi", 
            [:scenario, 2, "Scenario:", "Hello", 
              [:step, 3, "Given", "foo"],
              [:comment, "# When bar\n"], 
              [:step, 5, "Then", "baz"] 
            ]
          ]
        end

        it "should parse a file with only a multiline comment" do
          parse(%{# Hello
# World
Feature: hi
}).to_sexp.should ==
          [:feature, nil, "Feature: hi\n",
            [:comment, "# Hello\n# World\n"]]
        end

        it "should parse a file with no comments" do
          parse("Feature: hi\n").to_sexp.should ==
          [:feature, nil, "Feature: hi\n"]
        end

        it "should parse a file with only a multiline comment with newlines" do
          parse("# Hello\n\n# World\n").to_sexp.should == 
          [:feature, nil, "", 
            [:comment, "# Hello\n\n# World\n"]]
        end
      end

      describe "Tags" do
        it "should parse a file with tags on a feature" do
          parse("# My comment\n@hello @world Feature: hi\n").to_sexp.should ==
          [:feature, nil, "Feature: hi\n",
            [:comment, "# My comment\n"],
            [:tag, "hello"],
            [:tag, "world"]]
        end

        it "should parse a file with tags on a scenario" do
          parse(%{# FC
  @ft
Feature: hi

  @st1 @st2   
  Scenario: First
    Given Pepper

@st3 
   @st4    @ST5  @#^%&ST6**!
  Scenario: Second}).to_sexp.should ==
          [:feature, nil, "Feature: hi",
            [:comment, "# FC\n  "],
            [:tag, "ft"],
            [:scenario, 6, 'Scenario:', 'First',
              [:tag, "st1"], [:tag, "st2"],
              [:step_invocation, 7, "Given", "Pepper"]
            ],
            [:scenario, 11, 'Scenario:', 'Second',
              [:tag, "st3"], [:tag, "st4"], [:tag, "ST5"], [:tag, "#^%&ST6**!"]]]
        end
      end
      
      describe "Background" do
        it "should have steps" do
          parse("Feature: Hi\nBackground:\nGiven I am a step\n").to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:background, 2, "Background:",
              [:step, 3, "Given", "I am a step"]]]
        end
      end

      describe "Scenarios" do
        it "can be empty" do
          parse("Feature: Hi\n\nScenario: Hello\n").to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:scenario, 3, "Scenario:", "Hello"]]
        end

        it "should allow whitespace lines after the Scenario line" do
          parse(%{Feature: Foo

Scenario: bar

  Given baz})
        end
            
        it "should have steps" do
          parse("Feature: Hi\nScenario: Hello\nGiven I am a step\n").to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:scenario, 2, "Scenario:", "Hello",
              [:step_invocation, 3, "Given", "I am a step"]]]
        end

        it "should have steps with inline table" do
          parse(%{Feature: Hi
Scenario: Hello
Given I have a table
|a|b|
}).to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:scenario, 2, "Scenario:", "Hello",
              [:step_invocation, 3, "Given", "I have a table",
                [:table,
                  [:row,
                    [:cell, "a"],
                    [:cell, "b"]]]]]]
        end

        it "should have steps with inline py_string" do
          parse(%{Feature: Hi
Scenario: Hello
Given I have a string


   """
  hello
  world
  """

}).to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:scenario, 2, "Scenario:", "Hello",
              [:step_invocation, 3, "Given", "I have a string",
                [:py_string, "hello\nworld"]]]]
        end
      end

      describe "Scenario Outlines" do
        it "can be empty" do
          parse(%{Feature: Hi
Scenario Outline: Hello
Given a <what> cucumber
Examples:
|what|
|green|
}).to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:scenario_outline, "Scenario Outline:", "Hello",
              [:step, 3, "Given", "a <what> cucumber"],
              [:examples, "Examples:", "",
                [:table, 
                  [:row, 
                    [:cell, "what"]], 
                    [:row, [:cell, "green"]]]]]]
        end

        it "should have line numbered steps with inline table" do
          parse(%{Feature: Hi
Scenario Outline: Hello

Given I have a table

|<a>|<b>|
Examples:
|a|b|
|c|d|
}).to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:scenario_outline, "Scenario Outline:", "Hello",
              [:step, 4, "Given", "I have a table",
                [:table, 
                  [:row, 
                    [:cell, "<a>"], 
                    [:cell, "<b>"]]]],
            [:examples, "Examples:", "",
              [:table,
                [:row, 
                  [:cell, "a"], 
                  [:cell, "b"]],
                [:row, 
                  [:cell, "c"], 
                  [:cell, "d"]]]]]]
        end

        it "should have examples" do
          parse("Feature: Hi

  Scenario Outline: Hello

  Given I have a table
    |1|2|

  Examples:
|x|y|
|5|6|

").to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:scenario_outline, "Scenario Outline:", "Hello",
              [:step, 5, "Given", "I have a table",
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

        it "should set line numbers on feature" do
          feature = parse_file("empty_feature.feature:11:12")
          feature.instance_variable_get('@lines').should == [11, 12]
        end
      end

      describe "Syntax" do
        it "should parse empty_feature" do
          parse_file("empty_feature.feature")
        end

        it "should parse empty_scenario" do
          parse_file("empty_scenario.feature")
        end

        it "should parse empty_scenario_outline" do
          parse_file("empty_scenario_outline.feature")
        end

        it "should parse fit_scenario" do
          parse_file("multiline_steps.feature")
        end

        it "should parse scenario_outline" do
          parse_file("scenario_outline.feature")
        end
      end
    end
  end
end
