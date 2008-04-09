require File.dirname(__FILE__) + '/../spec_helper.rb'

module Stories
  describe Parser do
    describe "with two defined steps" do
      before do
        @story_parser = StoryParser.new
      end
      
      it "should parse a story matching those steps" do
        story = "Story: hello world\nAs a bla\nScenario: Doit\nGiven I was 5here4 and there"
        story_tree = @story_parser.should parse(story)

        # TODO: Use a custom matcher
        if story_tree
          puts story_tree.inspect
        else
          puts @story_parser.failure_reason
        end
      end
    end
  end
end