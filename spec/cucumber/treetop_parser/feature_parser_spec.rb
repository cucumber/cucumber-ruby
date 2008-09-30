require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module TreetopParser
    describe FeatureParser do
      it "should parse features with weird spaces" do
        p = FeatureParser.new
        f = p.parse_feature(File.dirname(__FILE__) + '/spaces.feature')
        f.header.should == "Some title"
        f.should have(2).scenarios

        first = f.scenarios[0]
        first.name.should == "first"
        first.should have(1).steps
        first.steps[0].name.should == "a"

        second = f.scenarios[1]
        second.name.should == "second"
        second.should have(1).steps
        second.steps[0].name.should == "b"
      end
      
      it "should parse GivenScenario" do
        p = FeatureParser.new
        f = p.parse_feature(File.dirname(__FILE__) + '/given_scenario.feature')

        f.header.should == "Some title"
        f.should have(2).scenarios

        first = f.scenarios[0]
        first.should have(2).steps

        second = f.scenarios[1]
        second.should have(3).steps
      end
      
      it "should allow spaces between FIT values" do
        p = FeatureParser.new
        Cucumber::Tree::RowScenario.should_receive(:new).with(anything, anything, ['I can have spaces'], anything)
        
        f = p.parse_feature(File.dirname(__FILE__) + '/fit_scenario.feature')
      end
      
      it "should allow comments in feature files" do
        p = FeatureParser.new
        f = p.parse_feature(File.dirname(__FILE__) + '/with_comments.feature')
        f.scenarios[0].should have(2).steps
      end

      it "should allow empty scenarios" do
        p = FeatureParser.new
        f = p.parse_feature(File.dirname(__FILE__) + '/empty_scenario.feature')
        f.scenarios[0].should have(1).steps
        f.scenarios[1].should have(0).steps
        f.scenarios[2].should have(1).steps
      end

      it "should allow multiple tables" do
        p = FeatureParser.new
        f = p.parse_feature(File.dirname(__FILE__) + '/multiple_tables.feature')
        f.should have(6).scenarios
        f.scenarios[0].should have(5).steps
      end

      it "should allow empty features" do
        p = FeatureParser.new
        f = p.parse_feature(File.dirname(__FILE__) + '/empty_feature.feature')
        f.should have(0).scenarios
      end
      
    end
  end
end