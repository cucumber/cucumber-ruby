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
          comment = parse("# My comment\nFeature: hi\n").comment
          comment.extend(Module.new{
            attr_reader :value
          })
          comment.value.should == "# My comment\n"
        end

        it "should parse a file with only a multiline comment" do
          comment = parse("# Hello\n# World\nFeature: hi\n").comment
          comment.extend(Module.new{
            attr_reader :value
          })
          comment.value.should == "# Hello\n# World\n"
        end

        it "should parse a file with no comments" do
          comment = parse("Feature: hi\n").comment
          comment.extend(Module.new{
            attr_reader :value
          })
          comment.value.should == ""
        end

        it "should parse a file with only a multiline comment with newlines" do
          pending do
            parse("# Hello\n\n# World\n").comment.should == "# Hello\n# World"
          end
        end
      end

      describe "Tags" do
        it "should parse a file with tags on a feature" do
          tags = parse("# My comment\n@hello @world Feature: hi\n").tags
          tags.extend(Module.new{
            attr_reader :tag_names
          })
          tags.tag_names.should == %w{hello world}
        end
      end

      describe "Scenarios" do
        it "can be empty" do
          scenario = parse("Feature: Hi\nScenario: Hello\n").feature_elements[0]
          scenario.extend(Module.new{
            attr_reader :name
          })
          scenario.name.should == "Hello"
        end

        it "should have steps" do
          scenario = parse("Feature: Hi\nScenario: Hello\nGiven I am a step\n").feature_elements[0]
          step = scenario.instance_variable_get('@steps')[0]
          gwt  = step.instance_variable_get('@gwt').should == 'Given'
          name = step.instance_variable_get('@name').should == 'I am a step'
        end

        it "should have steps with inline table" do
          scenario = parse("Feature: Hi\nScenario: Hello\nGiven I have a table\n|1|2|\n").feature_elements[0]
          step = scenario.instance_variable_get('@steps')[0]
          table = step.instance_variable_get('@multiline_args')[0]
          table.raw.should == [['1', '2']]
        end
      end

      describe "Scenario Outlines" do
        it "can be empty" do
          scenario_outline = parse("Feature: Hi\nScenario Outline: Hello\nExamples:\n|1|2|\n").feature_elements[0]
          scenario_outline.extend(Module.new{
            attr_reader :name
          })
          scenario_outline.name.should == "Hello"
        end

        it "should have steps with inline table" do
          scenario_outline = parse("Feature: Hi\nScenario Outline: Hello\nGiven I have a table\n|1|2|\n").feature_elements[0]
          step = scenario_outline.instance_variable_get('@steps')[0]
          table = step.instance_variable_get('@multiline_args')[0]
          table.raw.should == [['1', '2']]
        end

        it "should have examples" do
          scenario_outline = parse("Feature: Hi\nScenario Outline: Hello\nGiven I have a table\n|1|2|\nExamples:\n|x|y|\n|1|2|").feature_elements[0]
          examples = scenario_outline.instance_variable_get('@examples')
          examples_table = examples.instance_variable_get('@outline_table')
          examples_table.raw.should == [%w{x y}, %w{1 2}]
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