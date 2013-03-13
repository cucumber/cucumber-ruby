require 'spec_helper'
require 'cucumber/ast/feature_factory'

module Cucumber
  module Ast
    describe Features do
      it "has a step_count" do
        parse_feature(<<-GHERKIN)
Feature:
  Background:
    Given step 1
    And step 2

  Scenario:
    Given step 3
    And step 4
    And step 5

  Scenario Outline:
    Given step <n>
    And another step

    Examples:
      | n |
      | 6 |
      | 7 |

    Examples:
      | n |
      | 8 |
GHERKIN

        features.step_count.should == (2 + 3) + (3 * (2 + 2))
      end

      def parse_feature(gherkin)
        path    = 'features/test.feature'
        builder = Cucumber::Parser::GherkinBuilder.new(path)
        parser  = Gherkin::Parser::Parser.new(builder, true, "root", false)
        parser.parse(gherkin, path, 0)
        builder.language = parser.i18n_language
        feature = builder.result
        features.add_feature(feature)
      end

      let(:features) { Features.new }

    end
  end
end

