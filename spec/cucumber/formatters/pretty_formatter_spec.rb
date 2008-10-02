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
          :row? => false}.merge(stubs))
      end
    
      def mock_error(stubs={})
        stub('error', {
          :message => 'failed', 
          :backtrace => 'example backtrace'}.merge(stubs))
      end
      
      def mock_proc
        stub(Proc, :to_s => '#<Proc:0x011ebe18@./steps/example_steps.rb:11>')
      end
            
      it "should print step file and line when passed" do
        io = StringIO.new
        formatter = PrettyFormatter.new io, StepMother.new
        step = stub('step',
          :error => nil, :row? => false, :keyword => 'Given', :format => 'formatted yes'
        )
        formatter.step_passed(step,nil,nil)
        io.string.should == "    Given formatted yes\n"
      end
      
      describe "show source option true" do
      
        it "should display step source for passed step" do
          io = StringIO.new
          formatter = PrettyFormatter.new io, StepMother.new, :source => true
          formatter.step_passed(mock_step(:regexp_args_proc => [nil, nil, mock_proc]), nil, nil)
          
          io.string.should include("Given formatted yes  #steps/example_steps.rb:11")
        end
        
        it "should display step source for failed step" do
          io = StringIO.new
          formatter = PrettyFormatter.new io, StepMother.new, :source => true
          formatter.step_failed(mock_step(:regexp_args_proc => [nil, nil, mock_proc], :error => mock_error), nil, nil)
          
          io.string.should include("Given formatted yes  #steps/example_steps.rb:11")
        end
        
        it "should NOT display step source for pending step" do
          io = StringIO.new
          formatter = PrettyFormatter.new io, StepMother.new, :source => true
          formatter.step_pending(mock_step(:regexp_args_proc => [nil, nil, mock_proc]), nil, nil)
          
          io.string.should_not include("Given formatted yes   #steps/example_steps.rb:11")
        end
        
      end
    end
  end
end
