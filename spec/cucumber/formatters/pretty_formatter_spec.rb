require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Formatters
    describe PrettyFormatter do

      def mock_step(stubs={})
        stub('step', {
          :keyword => 'Given',
          :format => 'formatted yes',
          :name => 'example',
          :error => nil,
          :padding_length => 2,
          :file => 'test',
          :line => 1,
          :row? => false}.merge(stubs))
      end

      def mock_scenario(stubs={})
        stub('scenario', {
          :name => 'test',
          :row? => false,
          :pending? => false,
          :file => 'file', 
          :line => 1,
          :padding_length => 2}.merge(stubs))
      end

      def mock_feature(stubs={})
        stub("feature", stubs)
      end

      def mock_error(stubs={})
        stub('error', {
          :message => 'failed',
          :backtrace => 'example backtrace'}.merge(stubs))
      end

      def mock_proc
        stub(Proc, :to_comment_line => '# steps/example_steps.rb:11')
      end

      it "should print step file and line when passed" do
        io = StringIO.new
        formatter = PrettyFormatter.new io, StepMother.new
        step = stub('step',
          :error => nil, :row? => false, :keyword => 'Given', :format => 'formatted yes'
        )
        formatter.step_passed(step, nil, nil)
        io.string.should == "    Given formatted yes\n"
      end

      describe "scenario without any steps" do
        before :each do
          @io         = StringIO.new
          @formatter  = PrettyFormatter.new(@io, StepMother.new)
          @scenario   = mock_scenario(:name => "title", :pending? => true)
        end

        it "should display as pending when executing" do
          @formatter.should_receive(:pending).with("  Scenario: title")
          @formatter.scenario_executing(@scenario)
        end

        it "should display as pending in the dump" do
          @formatter.scenario_executing(@scenario)
          @formatter.dump
          @io.string.should include("1 scenarios pending")
        end
      end
      
      it "should put a line between last row scenario and new scenario" do
        io = StringIO.new
        formatter = PrettyFormatter.new io, mock('step_mother'), :source => true
        scenario = mock_scenario(:row? => true)
  
        formatter.scenario_executing(scenario)
        formatter.scenario_executed(scenario)
        formatter.scenario_executing(mock_scenario(:name => 'spacey', :row? => false))
     
        io.string.should =~ /\n\n  Scenario: spacey/
      end
      
      {'should' => true, 'should not' => false}.each do |should_or_should_not, show_snippet|
        describe "snippets option #{show_snippet}" do
          
          it "#{should_or_should_not} show snippet for pending step" do
            @io = StringIO.new
            step_mother = mock('step_mother', :has_step_definition? => false)
            @formatter = PrettyFormatter.new @io, step_mother, :snippets => show_snippet
                    
            @formatter.step_pending(mock_step(:actual_keyword => 'Given', :name => 'pending step snippet'), nil, nil)
            @formatter.dump

            @io.string.send(should_or_should_not.gsub(' ','_').to_sym, include("Given /^pending step snippet$/ do"))
          end
        
        end
      end                  
      
      it  "should escape snippets which have special regular expression characters" do
        @io = StringIO.new
        step_mother = mock('step_mother', :has_step_definition? => false)
        @formatter = PrettyFormatter.new @io, step_mother, :snippets => true

        @formatter.step_pending(mock_step(:actual_keyword => 'Given', :name => "$1 millon /'s"), nil, nil)
        @formatter.dump

        @io.string.should include("Given /^\\$1 millon \\/'s$/ do")
      end
          
      it "should not show the snippet for a step which already has a step definition" do
        @io = StringIO.new
        step_mother = mock('step_mother', :has_step_definition? => true)
        @formatter = PrettyFormatter.new @io, step_mother, :snippets => true

        @formatter.step_pending(mock_step(:actual_keyword => 'Given', :name => 'pending step snippet'), nil, nil)
        @formatter.dump

        @io.string.should_not include("Given /^pending step snippet$/ do")
      end
      
      describe "show source option true" do

        before(:each) do
          @io = StringIO.new
          step_mother = mock('step_mother')
          @formatter = PrettyFormatter.new @io, step_mother, :source => true
        end

        %w{passed failed skipped}.each do |result|
          it "should display step source for #{result} step" do
            @formatter.send("step_#{result}".to_sym, mock_step(:regexp_args_proc => [nil, nil, mock_proc], :error => StandardError.new, :padding_length => 2), nil, nil)

            @io.string.should include("Given formatted yes  # steps/example_steps.rb:11")
          end
        end

        it "should display feature file and line for pending step" do
          @formatter.step_pending(mock_step(:name => 'test', :file => 'features/example.feature', :line => 5, :padding_length => 2), nil, nil)

          @io.string.should include("Given test  # features/example.feature:5")
        end

        it "should display file and line for scenario" do
          @formatter.scenario_executing(mock_scenario(:name => "title", :file => 'features/example.feature', :line => 2 , :padding_length => 2, :pending? => false))

          @io.string.should include("Scenario: title  # features/example.feature:2")
        end

        it "should display file for feature" do
          @formatter.feature_executing(mock_feature(:file => 'features/example.feature', :padding_length => 2))
          @formatter.header_executing("Feature: test\n In order to ...\n As a ...\n I want to ...\n")

          @io.string.should include("Feature: test  # features/example.feature\n")
          @io.string.should include("In order to ...\n")
          @io.string.should include("As a ...\n")
          @io.string.should include("I want to ...\n")
        end

        it "should align step comments" do
          step_1 = mock_step(:regexp_args_proc => [nil, nil, mock_proc], :format => "1", :padding_length => 10)
          step_4 = mock_step(:regexp_args_proc => [nil, nil, mock_proc], :format => "4444", :padding_length => 7)
          step_9 = mock_step(:regexp_args_proc => [nil, nil, mock_proc], :format => "999999999", :padding_length => 2)

          @formatter.step_passed(step_1, nil, nil)
          @formatter.step_passed(step_4, nil, nil)
          @formatter.step_passed(step_9, nil, nil)

          @io.string.should include("Given 1          # steps/example_steps.rb:11")
          @io.string.should include("Given 4444       # steps/example_steps.rb:11")
          @io.string.should include("Given 999999999  # steps/example_steps.rb:11")
        end

        it "should align step comments with respect to their scenario's comment" do
          step = mock_step(:regexp_args_proc => [nil, nil, mock_proc], :error => StandardError.new, :padding_length => 6)

          @formatter.scenario_executing(mock_scenario(:name => "very long title", :file => 'features/example.feature', :line => 5, :steps => [step], :padding_length => 2, :pending? => false))
          @formatter.step_passed(step, nil, nil)

          @io.string.should include("Scenario: very long title  # features/example.feature:5")
          @io.string.should include("  Given formatted yes      # steps/example_steps.rb:11")
        end

      end

      it "should reset the column count correctly" do
        io = StringIO.new
        formatter = PrettyFormatter.new io, mock('step_mother'), :source => true

        large_scenario = mock_scenario(:row? => false, :table_column_widths => [3,3,5,4,4], :table_header => %w(one two three four five))
        formatter.scenario_executing(large_scenario)
        formatter.scenario_executed(large_scenario)

        small_scenario = mock_scenario(:row? => false, :table_column_widths => [3,3], :table_header => %w(one two))
        formatter.scenario_executing(small_scenario)
        lambda {
          formatter.scenario_executed(small_scenario)
        }.should_not raise_error(TypeError)
      end

    end
  end
end
