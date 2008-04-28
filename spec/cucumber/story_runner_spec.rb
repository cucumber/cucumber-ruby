require File.dirname(__FILE__) + '/../spec_helper'

module Cucumber
  describe StoryRunner do
    def fixture(file)
      File.dirname(__FILE__) + "/../../fixture_stories/#{file}"
    end
  
    before do
      @f = mock('formatter')
      @r = StoryRunner.new(@f)
      @f.stub! :story_executed
      @f.stub! :narrative_executed
      @f.stub! :scenario_executed
      @r.load(fixture('sell_cucumbers.story'))
    end
  
    it "should report a nice backtrace to formatter" do
      class Foo < StandardError
      end

      @r.register_proc('there are 5 cucumber') do
        raise Foo
      end
      
      first = true
      @f.should_receive(:step_executed).exactly(9).times do |step, name, line, e|
        if first
          dir = File.dirname(__FILE__)
          e.backtrace.should == [
            "#{dir}/story_runner_spec.rb:23",
            "#{dir}/../../fixture_stories/sell_cucumbers.story:7: in `Given there are 5 cucumber'"
          ]
          first = false
        end
      end
      
      @r.run
    end
  end
end