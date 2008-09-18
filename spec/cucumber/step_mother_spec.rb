require File.dirname(__FILE__) + '/../spec_helper'

module Cucumber
  describe StepMother do
    it "should report file and line numbers for both duplicate step definitions" do
      m = StepMother.new
      
      m.register_step_proc /Three (.*) mice/ do |disability|
      end

      begin
        m.register_step_proc /Three (.*) mice/ do |disability|
        end
        violated("Should raise error")
      rescue => e
        e.message.should =~ %r{Duplicate step definitions:.+step_mother_spec\.rb:8:in `/Three \(\.\*\) mice/'.+step_mother_spec\.rb\:12:in `/Three \(\.\*\) mice/'}m

      end
    end

    it "should report file and line numbers for multiple step definitions" do
      m = StepMother.new
      
      m.register_step_proc /Three (.*) mice/ do |disability|
      end

      m.register_step_proc /Three blind (.*)/ do |animal|
      end

      begin
        m.regexp_args_proc('Three blind mice')
        violated("Should raise error")
      rescue => e
        e.message.should =~ %r{Multiple step definitions match "Three blind mice":

.+step_mother_spec\.rb:24:in `/Three \(\.\*\) mice/'
.+step_mother_spec\.rb:27:in `/Three blind \(\.\*\)/'

}m
      end
    end
    
    it "should mark step as pending when it doesn't match any procs" do
      pending "think some more about what to expect here" do
        m = StepMother.new
        step = mock('step')
        step.should_receive(:pending!)
        raise "FIXME"
        m.execute(step)
      end
    end
  end
end
