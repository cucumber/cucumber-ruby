require File.dirname(__FILE__) + '/../spec_helper'

module Cucumber
  describe StoryRunner do
    def fixture(file)
      File.dirname(__FILE__) + "/../../fixture_stories/#{file}"
    end
  
    before do
      @r = StoryRunner.new
    end
  
    it "should create a nice backtrace" do
      @r.register_proc('there are 5 cucumber') do
        raise "No way"
      end
      
      begin
        @r.execute(fixture('sell_cucumbers.story'))
        violated
      rescue => e
        e.message.should == "No way"
        e.backtrace.should == [
          "./spec/cucumber/story_runner_spec.rb:15",
          "./spec/cucumber/../../fixture_stories/sell_cucumbers.story:7: in `Given there are 5 cucumber'"
        ]
      end
    end
  end
end