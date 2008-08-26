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
        e.message.should == %{Duplicate step definitions:

spec/cucumber/step_mother_spec.rb:8:in `/Three (.*) mice/'
spec/cucumber/step_mother_spec.rb:12:in `/Three (.*) mice/'
}
      end
    end

    it "should report file and line numbers for both ambiguous step definitions" do
      m = StepMother.new
      
      m.register_step_proc /Three (.*) mice/ do |disability|
      end

      m.register_step_proc /Three blind (.*)/ do |animal|
      end

      begin
        m.regexp_and_args_for('Three blind mice')
        violated("Should raise error")
      rescue => e
        e.message.should == %{Ambiguos step resolution for "Three blind mice":

spec/cucumber/step_mother_spec.rb:27:in `/Three (.*) mice/'
spec/cucumber/step_mother_spec.rb:30:in `/Three blind (.*)/'
}
      end
    end
  end
end
