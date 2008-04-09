require File.dirname(__FILE__) + '/../spec_helper.rb'

module Stories
  describe RuleFactory do
    before do
      @rf = RuleFactory.new
    end
    
    it "should translate a rule with zero arguments" do
      @rf.rule_for("hello world").should == "'hello world'"
    end

    it "should translate a rule with two arguments" do
      @rf.rule_for("I was $one and $two").should == "'I was ' word ' and ' word"
    end
  end
end