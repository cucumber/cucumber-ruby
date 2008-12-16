require File.dirname(__FILE__) + '/../../spec_helper'
require 'stringio'
require 'cucumber/ast'
require 'cucumber/formatter/pretty'

module Cucumber
  module Formatter
    describe Pretty do
      class MyWorld
        def flunk
          raise "I flunked"
        end
      end
      
      it "should format itself" do
        f = Ast::Feature.new(
          Ast::Comment.new("# My feature comment\n"),
          Ast::Tags.new(['one', 'two']),
          "Pretty printing",
          [Ast::Scenario.new(
            Ast::Comment.new("    # My scenario comment  \n# On two lines \n"),
            Ast::Tags.new(['three']),
            "A Scenario",
            [
              step1=Ast::Step.new("Given", "A step var1 and var2"),
              step2=Ast::Step.new("Given", "A step var1 and var2")
            ]
          )]
        )
        
        step2.step_def = StepDefinition.new /A step (.*) and (.*)/ do |a, b|
          flunk
        end

        world = MyWorld.new
        step1.execute_in(world)
        step2.execute_in(world)

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
    \e[33mGiven A step var1 and var2\e[0m
    \e[31mGiven A step \e[31m\e[1mvar1\e[0m\e[0m\e[31m and \e[31m\e[1mvar2\e[0m\e[0m\e[31m\e[0m
      I flunked
      ./spec/cucumber/formatter/pretty_spec.rb:11:in `flunk'
      ./spec/cucumber/formatter/pretty_spec.rb:32:in `(?-mix:A step (.*) and (.*))'
}
      end
    end
  end
end
