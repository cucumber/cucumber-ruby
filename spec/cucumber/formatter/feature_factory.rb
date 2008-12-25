module Cucumber
  module Formatter
    module FeatureFactory
      class MyWorld
        def flunk
          raise "I flunked"
        end
      end
      
      def create_feature(step_mother)
        step_mother.extend(StepMom)
        step_mother.Given /^a (.*) step with an inline arg:$/ do |what, table|
        end
        step_mother.Given /^a (.*) step$/ do |what|
          flunk if what == 'failing'
        end
        step_mother.World do
          MyWorld.new
        end

        table = Ast::Table.new([
          %w{1 22 333},
          %w{4444 55555 666666}
        ])
        py_string = Ast::PyString.new(%{I like
          Cucumber sandwich
        })
        f = Ast::Feature.new(
          Ast::Comment.new("# My feature comment\n"),
          Ast::Tags.new(['one', 'two']),
          "Pretty printing",
          [Ast::Scenario.new(
            step_mother,
            Ast::Comment.new("    # My scenario comment  \n# On two lines \n"),
            Ast::Tags.new(['three', 'four']),
            "A Scenario",
            [
              ["Given", "a passing step with an inline arg:", table],
              ["Given", "a happy step with an inline arg:", py_string],
              ["Given", "a failing step"]
            ]
          )]
        )
      end
    end
  end
end