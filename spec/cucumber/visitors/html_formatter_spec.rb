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
      end
      
      it "should render HTML" do
        @formatter.visit_stories(@stories)
        @io.string.should == IO.read(File.dirname(__FILE__) + '/stories.html')
      end
    end
  end
end
