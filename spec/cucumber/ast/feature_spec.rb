require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/ast'
require 'stringio'

module Cucumber
  module Ast
    describe Feature do
      it "should format itself" do
        f = Feature.new(Comment.new("# My comment\n"), Tags.new(['one', 'two']), [])
        io = StringIO.new
        f.format(io)
        io.rewind
        io.read.should == %{# My comment\n@one @two\n}
      end
    end
  end
end
