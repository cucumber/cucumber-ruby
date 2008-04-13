require File.dirname(__FILE__) + '/../spec_helper.rb'
require 'stringio'

module Cucumber
  describe Runner do
    describe "with two defined string steps" do
      before do
        @err = StringIO.new
        @out = StringIO.new
        @runner = Runner.new(@err, @out)
      end
      
      it "should parse without error messages when a story matches those steps" do
        story = File.open(File.dirname(__FILE__) + '/fixtures/matching.story')
        @runner.add(story)
        @err.rewind
        @out.rewind
        @err.read.should == ""
        @out.read.should == ""
      end

      it "should parse with error messages when a story does not match those steps" do
        story = File.open(File.dirname(__FILE__) + '/fixtures/non_matching.story')
        @runner.add(story)
        @err.rewind
        @out.rewind
        @err.read.should == "Expected one of Given , When , Then , Scenario:  after \n"
        @out.read.should =~ /spec\/stories\/fixtures\/non_matching.story:4:1\n/
      end
    end
  end
end