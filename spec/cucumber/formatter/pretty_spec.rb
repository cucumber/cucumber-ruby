require File.dirname(__FILE__) + '/../../spec_helper'
require 'stringio'
require 'cucumber/ast'
require 'cucumber/step_mom'
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
        step_mother = Object.new
        step_mother.extend(StepMom)
        step_mother.Given /^a (.*) step with a table:$/ do |what, table|
        end
        step_mother.Given /^a (.*) step$/ do |what|
          flunk if what == 'failing'
        end

        table =Ast::Table.new([
          %w{1 22 333},
          %w{4444 55555 666666}
        ])
        f = Ast::Feature.new(
          Ast::Comment.new("# My feature comment\n"),
          Ast::Tags.new(['one', 'two']),
          "Pretty printing",
          [Ast::Scenario.new(
            Ast::Comment.new("    # My scenario comment  \n# On two lines \n"),
            Ast::Tags.new(['three', 'four']),
            "A Scenario",
            [
              step1=Ast::Step.new(step_mother, "Given", "a passing step with a table:", table),
              step2=Ast::Step.new(step_mother, "Given", "a failing step")
            ]
          )]
        )
        
        world = MyWorld.new
        step1.world = world
        step2.world = world

        io = StringIO.new
        pretty = Formatter::Pretty.new(step_mother, io)
        pretty.visit_feature(f)

        io.rewind
        io.read.should == %{# My feature comment
@one @two
Feature: Pretty printing

  # My scenario comment
  # On two lines
  @three @four
  Scenario: A Scenario
    \e[32mGiven a \e[32m\e[1mpassing\e[0m\e[0m\e[32m step with a table:\e[0m
      | 1    | 22    | 333    |
      | 4444 | 55555 | 666666 |
    \e[31mGiven a \e[31m\e[1mfailing\e[0m\e[0m\e[31m step\e[0m
      I flunked
      ./spec/cucumber/formatter/pretty_spec.rb:12:in `flunk'
      ./spec/cucumber/formatter/pretty_spec.rb:22:in `(?-mix:^a (.*) step$)'
}
      end
    end
  end
end
