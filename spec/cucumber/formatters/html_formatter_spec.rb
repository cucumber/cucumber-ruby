require File.dirname(__FILE__) + '/../../spec_helper'
require 'stringio'

module Cucumber
  module Formatters
    describe HtmlFormatter do
      SIMPLE_DIR = File.dirname(__FILE__) + '/../../../examples/simple'
      
      before do
        p = Parser::StoryParser.new
        @stories = Parser::StoriesNode.new(Dir["#{SIMPLE_DIR}/*.story"], p)
        @io = StringIO.new
        @formatter = HtmlFormatter.new(@io)
      end
      
      it "should render HTML" do
        @formatter.visit_stories(@stories)
        @formatter.dump
        expected_html = File.dirname(__FILE__) + '/stories.html'
        #File.open(expected_html, 'w') {|io| io.write(@io.string)}
        @io.string.should == IO.read(expected_html)
      end
    end
  end
end
