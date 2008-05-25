require File.dirname(__FILE__) + '/../../spec_helper'
require 'stringio'
require 'cucumber/visitors/html_formatter'

module Cucumber
  module Visitors
    describe HtmlFormatter do
      before do
        f = File.dirname(__FILE__) + '/../sell_cucumbers.story'
        p = Parser::StoryParser.new
        @stories = Stories.new([f], p)
        @io = StringIO.new
        @formatter = HtmlFormatter.new(@io)
        @executor = Executor.new(@formatter)
      end
      
      it "should render HTML" do
        @executor.visit_stories(@stories)
        expected_stories = File.dirname(__FILE__) + '/stories.html'
        # File.open(expected_stories, 'w') {|io| io.write(@io.string)}
        @io.string.should == IO.read(expected_stories)
      end
    end
  end
end
