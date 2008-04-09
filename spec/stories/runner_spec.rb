require File.dirname(__FILE__) + '/../spec_helper.rb'
require 'stringio'

module Stories
  describe Runner do
    describe "with two defined steps" do
      before do
        rule_factory = mock("RuleFactory")
        rule_factory.should_receive(:rule_for).with("I was $one and $two").and_return("'I was ' word ' and ' word")
        rule_factory.should_receive(:rule_for).with("I am $three and $four").and_return("'I am ' word ' and ' word")
        
        @err = StringIO.new
        @out = StringIO.new
        @runner = Runner.new(rule_factory, @err, @out)
        @runner.step "I was $one and $two" do |one, two| # 'I was ' word ' and ' word
          
        end
        @runner.step "I am $three and $four" do |three, four| # 'I am ' word ' and ' word
          
        end
        @runner.compile
      end
      
      it "should parse without error messages when a story matches those steps" do
        story = "Story: hello world\nAs a bla\nScenario: Doit\nGiven I was 5here4 and there"
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
        @err.read.should == "Expected one of I was , I am  after Given \n"
        @out.read.should == "./spec/stories/fixtures/non_matching.story:4:7\n"
      end
    end
  end
end