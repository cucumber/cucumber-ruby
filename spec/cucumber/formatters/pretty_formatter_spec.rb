require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Formatters
    describe PrettyFormatter do
      it "should print step file and line when passed" do
        io = StringIO.new
        formatter = PrettyFormatter.new io
        step = stub('step',
          :error => nil, :row? => false, :keyword => 'Given', :format => 'formatted yes'
        )
        formatter.step_passed(step,nil,nil)
        io.string.should == "    Given formatted yes\n"
      end
    end
  end
end
