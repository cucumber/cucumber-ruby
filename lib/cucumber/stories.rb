module Cucumber
  class Stories
    def initialize(files, parser)
      @stories = files.map{|f| Parser::StoryNode.parse(f, parser)}
    end

    def accept(visitor)
      @stories.each{|story| visitor.visit_story(story)}
    end
  end
end