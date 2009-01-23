require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/formatter/profile'

module Cucumber
  module Formatter
    describe Progress do
      attr_reader :io, :formatter

      def mock_proc(stubs={})
        stub(Proc, {:to_comment_line => '# steps/example_steps.rb:11'}.merge(stubs))
      end

      def mock_step(stubs={})
        stub('step', {:keyword => 'Given',
          :actual_keyword =>  'Given',
          :format => 'test',
          :row? => false,
          :file => 'test.feature',
          :line => 5,
          :regexp_args_proc => [nil, nil, mock_proc]}.merge(stubs))
      end

      before(:each) do
        ::Term::ANSIColor.coloring = false
        @io = StringIO.new
        step_mother = stub('step_mother')
        @formatter = ProfileFormatter.new(step_mother, io)
      end
      
      after(:each) do
        ::Term::ANSIColor.coloring = true
      end

      xit "should print a heading" do
        formatter.visit_features(nil)

        io.string.should eql("Profiling enabled.\n")
      end

      xit "should record the current time when starting a new step" do
        now = Time.now
        Time.stub!(:now).and_return(now)
        formatter.step_executing('should foo', nil, nil)

        formatter.instance_variable_get("@step_time").should == now
      end
      
      describe "grouping recorded passed steps" do

        before(:each) do
          now = Time.now
          formatter.instance_variable_set("@step_time", now)
          Time.stub!(:now).and_return(now, now)
        end

        xit "should group by regular expressions and actual keyword" do
          step_1 = mock_step(:actual_keyword => 'Given')
          step_2 = mock_step(:actual_keyword => 'Given')

          formatter.step_passed(step_1, /nihon/, nil)
          formatter.step_passed(step_2, /ichiban/, nil)

          step_times = formatter.instance_variable_get("@step_times")

          step_times.has_key?('Given /nihon/').should be_true
          step_times.has_key?('Given /ichiban/').should be_true
        end

        xit "should use a previous step's keyword when recording row steps" do
          step = mock_step(:actual_keyword => 'Given')
          step_row = mock_step(:row? => true)

          formatter.step_passed(step, /nihon/, [])
          formatter.step_passed(step_row, /nihon/, [])

          step_times = formatter.instance_variable_get("@step_times")
          
          step_times['Given /nihon/'].length.should == 2
        end

      end

      xit "should correctly record a passed step" do
        formatter.step_executing(nil, nil, nil)
        formatter.step_passed(mock_step(:format => 'she doth teach the torches to burn bright', :actual_keyword => 'Given'), nil, nil)
        formatter.dump

        io.string.should include('Given she doth teach the torches to burn bright')
      end

      xit "should correctly record a passed step row" do
        formatter.step_executing(nil, nil, nil)
        formatter.step_passed(mock_step(:row? => true), /example/, ['fitty'])
        formatter.dump

        io.string.should include('fitty')
      end

      xit "should calculate the mean step execution time" do
        now = Time.now
        Time.stub!(:now).and_return(now, now+5, now, now+1)

        2.times do
          formatter.step_executing(mock_step, nil, nil)
          formatter.step_passed(mock_step, nil, nil)
        end

        formatter.dump

        io.string.should include('3.0000000')
      end

      xit "should display file and line comment for step invocation" do
        step = mock_step(:format => 'test', :actual_keyword => 'Given', :file => 'test.feature', :line => 5)

        formatter.step_executing(step, nil, nil)
        formatter.step_passed(step, nil, nil)
        formatter.dump

        @io.string.should include("# test.feature:5")
      end

      xit "should display file and line comment for step definition" do
        step = mock_step(:format => 'test', :actual_keyword => 'Given',
                         :regexp_args_proc => [/test/, nil, mock_proc(:to_comment_line => '# steps/example_steps.rb:11')])

        formatter.step_executing(step, nil, nil)
        formatter.step_passed(step, nil, nil)
        formatter.dump

        @io.string.should include("# steps/example_steps.rb:11")
      end

      xit "should show the performance times of the step invocations for a step definition" do
        now = Time.now
        Time.stub!(:now).and_return(now, now+5, now, now+1)

        step = mock_step(:format => 'step invocation', :actual_keyword => 'Given')

        2.times do
          formatter.step_executing(step, /example/, nil)
          formatter.step_passed(step, /example/, nil)
        end

        formatter.dump

        io.string.should include("3.0000000  Given /example/")
        io.string.should include("5.0000000  Given step invocation")
        io.string.should include("1.0000000  Given step invocation")
      end
      
      xit "should sort the step invocations in descending order" do
        now = Time.now
        Time.stub!(:now).and_return(now, now+1, now, now+5)
        
        step = mock_step(:format => 'step invocation', :actual_keyword => 'Given')
        
        2.times do
          formatter.step_executing(step, /example 1/, nil)
          formatter.step_passed(step, /example 1/, nil)
        end
        
        formatter.dump
        io_string_lines = io.string.split("\n")
        
        io_string_lines.at(-2).should include('5.0000000')
        io_string_lines.at(-1).should include('1.0000000')
      end

      xit "should print the top average 10 step results" do
        formatter.instance_variable_set("@step_time", Time.now)

        11.times do |test_number|
          step_regexp = Regexp.new "unique_test_#{test_number}"
          formatter.step_passed(mock_step(:format => 'test', :actual_keyword => 'Given',
          :regexp_args_proc => [step_regexp, nil, mock_proc]), step_regexp, nil)
        end

        formatter.dump

        io.string.scan(/unique_test_\d+/).length.should == 10
      end

      xit "should print the top 5 step invocations for step definition" do
        formatter.instance_variable_set("@step_time", Time.now)
   
        10.times do |test_number|
          formatter.step_passed(mock_step(:format => 'please invocate me', :actual_keyword => 'Given'), nil, nil)
        end

        formatter.dump

        io.string.scan(/please invocate me/).length.should == 5
      end

    end
  end
end
