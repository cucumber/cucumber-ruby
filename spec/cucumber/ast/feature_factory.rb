require 'cucumber/ast'
require 'cucumber/step_mother'
require 'gherkin/formatter/model'

module Cucumber
  module Ast
    module FeatureFactory
      class MyWorld
        def flunk
          raise "I flunked"
        end
      end

      def create_feature(dsl)
        dsl.Given /^a (.*) step with an inline arg:$/ do |what, table|
        end
        dsl.Given /^a (.*) step$/ do |what|
          flunk if what == 'failing'
        end
        dsl.World do
          MyWorld.new
        end

        table = Ast::Table.new([
          %w{1 22 333},
          %w{4444 55555 666666}
        ])
        doc_string = Ast::DocString.new(%{\n I like\nCucumber sandwich\n}, '')
        location = Ast::Location.new('foo.feature', 2)
        language = double.as_null_object

        background = Ast::Background.new(
          language,
          location,
          Ast::Comment.new(""), 
          "Background:", 
          "", 
          "",
          [
            Step.new(language, location.on_line(3), "Given", "a passing step")
          ]
        )

        location = Location.new('features/pretty_printing.feature', 0)

        Ast::Feature.new(
          location,
          background,
          Ast::Comment.new("# My feature comment\n"),
          Ast::Tags.new(6, [Gherkin::Formatter::Model::Tag.new('one', 6), Gherkin::Formatter::Model::Tag.new('two', 6)]),
          "Feature",
          "Pretty printing",
          "",
          [Ast::Scenario.new(
            language,
            location.on_line(9),
            background,
            Ast::Comment.new("    # My scenario comment  \n# On two lines \n"),
            Ast::Tags.new(8, [Gherkin::Formatter::Model::Tag.new('three', 8), Gherkin::Formatter::Model::Tag.new('four', 8)]),
            Ast::Tags.new(1, []),
            "Scenario:", "A Scenario", "",
            [
              Step.new(language, location.on_line(10), "Given", "a passing step with an inline arg:", table),
              Step.new(language, location.on_line(11), "Given", "a happy step with an inline arg:", doc_string),
              Step.new(language, location.on_line(12), "Given", "a failing step")
            ]
          )]
        )
      end
    end
  end
end
