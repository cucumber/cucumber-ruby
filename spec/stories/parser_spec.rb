require File.dirname(__FILE__) + '/../spec_helper.rb'

module Stories
  describe Runner do
    describe "with two defined steps" do
      before do
        @runner = Runner.new
        @runner.step "I was $one and $two" do |one, two| # 'I was ' word ' and ' word
          
        end
        @runner.step "I am $three and $four" do |three, four| # 'I am ' word ' and ' word
          
        end
        @runner.compile
      end
      
      it "should parse a story matching those steps" do
        story = "Story: hello world\nAs a bla\nScenario: Doit\nGiven I was 5here4 and there"
        @runner.parse(story)
      end

      it "should not parse a story not matching those steps" do
        story = "WHATEVER"
        lambda do
          @runner.parse(story)
        end.should raise_error(RuntimeError, /Expected Story:/)
      end
    end
  end
end