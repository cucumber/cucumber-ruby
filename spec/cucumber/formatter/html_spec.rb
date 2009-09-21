require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/formatter/html'
require 'nokogiri'

module Cucumber
  module Formatter
    describe Html do
      before(:each) do
        @out = StringIO.new
        @formatter = Html.new(mock("step mother"), @out, {})
      end

      it "should not raise an error when visiting a blank feature name" do
        lambda { @formatter.visit_feature_name("") }.should_not raise_error
      end
      
      describe "given a single feature" do
        before(:each) do
          @step_mother = StepMother.new
          feature_file = FeatureFile.new(nil, feature_file_content)
          features = Ast::Features.new
          features.add_feature feature_file.parse(@step_mother, {})
          
          # options = { :verbose => true }
          options = {}
          tree_walker = Cucumber::Ast::TreeWalker.new(@step_mother, [@formatter], options, STDOUT)
          tree_walker.visit_features(features)
          @doc = Nokogiri.HTML(@out.string)
        end
        
        Spec::Matchers.define :have_css_node do |css, regexp|
          match do |doc|
            nodes = doc.css(css)
            nodes.detect{ |node| node.text =~ regexp }
          end
        end
        
        describe "with a comment" do
          def feature_file_content
            <<-FEATURE
            # Healthy
            FEATURE
          end
          
          it { @out.string.should =~ /^\<!DOCTYPE/ }
          it { @out.string.should =~ /\<\/html\>$/ }
          it { @doc.should have_css_node('.feature .comment', /Healthy/) }
        end
        
        describe "with a tag" do
          def feature_file_content
            <<-FEATURE
            @foo
            FEATURE
          end

          it { @doc.should have_css_node('.feature .tag', /foo/) }
        end
        
        describe "with a narrative" do
          def feature_file_content
            <<-FEATURE
            Feature: Bananas
              In order to find my inner monkey
              As a human
              I must eat bananas
            FEATURE
          end

          it { @doc.should have_css_node('.feature h2', /Bananas/) }
          it { @doc.should have_css_node('.feature .narrative', /must eat bananas/) }
        end
        
        describe "with a background" do
          def feature_file_content
            <<-FEATURE
            Feature: Bananas
            
            Background:
              Given there are bananas
            FEATURE
          end

          it { @doc.should have_css_node('.feature .background', /there are bananas/) }
        end
        
        describe "with a scenario" do
          def feature_file_content
            <<-FEATURE
            Scenario: Monkey eats banana
              Given there are bananas
            FEATURE
          end

          it { @doc.should have_css_node('.feature h3', /Monkey eats banana/) }
          it { @doc.should have_css_node('.feature .scenario .step', /there are bananas/) }
        end
        
        describe "with a scenario outline" do
          def feature_file_content
            <<-FEATURE
            Scenario Outline: Monkey eats a balanced diet
              Given there are <Things>
            
              Examples: Fruit
               | Things  |
               | apples  |
               | bananas |
              Examples: Vegetables
               | Things   |
               | broccoli |
               | carrots  |
            FEATURE
          end
          
          it { @doc.should have_css_node('.feature .scenario.outline h4', /Fruit/) }
          it { @doc.should have_css_node('.feature .scenario.outline h4', /Vegetables/) }
          it { @doc.css('.feature .scenario.outline h4').length.should == 2}
          it { @doc.should have_css_node('.feature .scenario.outline table', //) }
          it { @doc.should have_css_node('.feature .scenario.outline table td', /carrots/) }
        end
        
        describe "with a step with a py string" do
          def feature_file_content
            <<-FEATURE
            Scenario: Monkey goes to town
              Given there is a monkey called:
               """
               foo
               """
            FEATURE
          end
          
          it { @doc.should have_css_node('.feature .scenario .val', /foo/) }
        end

        describe "with a multiline step arg" do
          def feature_file_content
            <<-FEATURE
            Scenario: Monkey goes to town
              Given there are monkeys:
               | name |
               | foo  |
               | bar  |
            FEATURE
          end
          
          it { @doc.should have_css_node('.feature .scenario table td', /foo/) }
        end

        
      end
    end
  end
end

