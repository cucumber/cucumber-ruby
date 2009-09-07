require File.dirname(__FILE__) + '/../../spec_helper'

describe Cucumber::Ast::Runner do
  describe "with listeners" do
    before(:each) do
      @listeners = [ mock('listener1'), mock('listener2') ]
      @runner = Cucumber::Ast::Runner.new(mock, @listeners, {})
    end
    
    it "should call each of the listeners" do
      features = mock('features', :accept => nil)
      @listeners.each do |listener|
        listener.should_receive(:visit_features).with(features)
      end
      @runner.visit_features(features)
    end
  end
end
