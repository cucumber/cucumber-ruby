require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/spec_helper'

require 'cucumber/formatter/junit'
require 'nokogiri'

module Cucumber::Formatter
  describe Junit do
    extend SpecHelperDsl
    include SpecHelper
    
    class TestDoubleJunitFormatter < Junit
      attr_reader :written_files
      
      def write_file(feature_filename, data)
        @written_files ||= {}
        @written_files[feature_filename] = data
      end
    end
    
    before(:each) do
      File.stub!(:directory?).and_return(true)
      @formatter = TestDoubleJunitFormatter.new(step_mother, '', {})
    end

    describe "given a single feature" do
      before(:each) do
        run_defined_feature
        @doc = Nokogiri.XML(@formatter.written_files.values.first)
      end
      
      describe "with a single scenario" do
        define_feature <<-FEATURE
          Feature: One passing scenario, one failing scenario

            Scenario: Passing
              Given a passing scenario
        FEATURE
        
        it { @doc.to_s.should =~ /One passing scenario, one failing scenario/ }
      end
      
      describe "with a scenario outline table" do
        define_steps do
          Given(/.*/) {  }
        end
        
        define_feature <<-FEATURE
          Feature: Eat things when hungry

            Scenario Outline: Eat things
              Given <Things>
            
            Examples: Good
              | Things   |
              | Cucumber |
              | Whisky   |
            Examples: Evil
              | Things   |
              | Big Mac  |
        FEATURE
        
        it { @doc.to_s.should =~ /Eat things when hungry/ }
        it { @doc.to_s.should =~ /Cucumber/ }
        it { @doc.to_s.should =~ /Whisky/ }
        it { @doc.to_s.should =~ /Big Mac/ }
        it { @doc.to_s.should_not =~ /Things/ }
        it { @doc.to_s.should_not =~ /Good|Evil/ }
      end
    end

  end
end