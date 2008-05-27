require File.dirname(__FILE__) + '/../../spec_helper'
require 'stringio'
require 'cucumber/visitors/html_formatter'

module Cucumber
  module Visitors
    describe HtmlFormatter do
      SIMPLE_DIR = File.dirname(__FILE__) + '/../../../examples/simple'
      
      before do
        p = Parser::StoryParser.new
        @stories = Stories.new(Dir["#{SIMPLE_DIR}/*.story"], p)
        @io = StringIO.new
        @formatter = HtmlFormatter.new(@io)
        @executor = Executor.new(@formatter)
      end
      
      it "should render HTML" do
        @executor.visit_stories(@stories)
        expected_stories = File.dirname(__FILE__) + '/stories.html'
        #File.open(expected_stories, 'w') {|io| io.write(@io.string)}
        @io.string.should == IO.read(expected_stories)
      end
    end
  end
end
