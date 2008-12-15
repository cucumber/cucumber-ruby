require File.dirname(__FILE__) + '/../../spec_helper'
require 'stringio'
require 'cucumber/ast'
require 'cucumber/formatter/pretty'

module Cucumber
  module Ast
    describe Feature do
      it "should format itself" do
        f = Feature.new(
          Comment.new("# My feature comment\n"),
          Tags.new(['one', 'two']),
          "Pretty printing",
          [Scenario.new(
            Comment.new("    # My scenario comment  \n# On two lines \n"),
            Tags.new(['three']),
            "A Scenario",
            []
          )]
        )

        io = StringIO.new
        pretty = Formatter::Pretty.new(io)
        pretty.visit_feature(f)

        io.rewind
        io.read.should == %{# My feature comment
@one @two
Feature: Pretty printing

  # My scenario comment
  # On two lines
  @three
  Scenario: A Scenario
}
      end
    end
  end
end
