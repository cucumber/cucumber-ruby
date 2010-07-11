require 'cucumber/ast'
require 'gherkin/rubify'

module Cucumber
  module Parser
    # This class conforms to the Gherkin event API and builds the
    # "legacy" AST. It will be replaced later when we have a new "clean"
    # AST.
    class GherkinBuilder
      include Gherkin::Rubify

      def ast
        @feature || @multiline_arg
      end

      def feature(statement, uri)
        @feature = Ast::Feature.new(
          nil, 
          Ast::Comment.new(statement.comments.map{|comment| comment.value}.join("\n")), 
          Ast::Tags.new(nil, statement.tags.map{|tag| tag.name}),
          statement.keyword,
          legacy_name_for(statement.name, statement.description),
          []
        )
      end

      def background(statement)
        @background = Ast::Background.new(
          Ast::Comment.new(statement.comments.map{|comment| comment.value}.join("\n")), 
          statement.line, 
          statement.keyword, 
          legacy_name_for(statement.name, statement.description), 
          steps=[]
        )
        @feature.background = @background
        @background.feature = @feature
        @step_container = @background
      end

      def scenario(statement)
        scenario = Ast::Scenario.new(
          @background, 
          Ast::Comment.new(statement.comments.map{|comment| comment.value}.join("\n")), 
          Ast::Tags.new(nil, statement.tags.map{|tag| tag.name}), 
          statement.line, 
          statement.keyword, 
          legacy_name_for(statement.name, statement.description), 
          steps=[]
        )
        @feature.add_feature_element(scenario)
        @background.feature_elements << scenario if @background
        @step_container = scenario
      end

      def scenario_outline(statement)
        scenario_outline = Ast::ScenarioOutline.new(
          @background, 
          Ast::Comment.new(statement.comments.map{|comment| comment.value}.join("\n")), 
          Ast::Tags.new(nil, statement.tags.map{|tag| tag.name}), 
          statement.line, 
          statement.keyword, 
          legacy_name_for(statement.name, statement.description), 
          steps=[],
          example_sections=[]
        )
        @feature.add_feature_element(scenario_outline)
        if @background
          @background = @background.dup
          @background.feature_elements << scenario_outline
        end
        @step_container = scenario_outline
      end

      def examples(statement, examples_rows)
        examples_fields = [
          Ast::Comment.new(statement.comments.map{|comment| comment.value}.join("\n")), 
          statement.line, 
          statement.keyword, 
          legacy_name_for(statement.name, statement.description), 
          matrix(examples_rows)
        ]
        @step_container.add_examples(examples_fields)
      end

      def step(statement, multiline_arg, result)
        @table_owner = Ast::Step.new(statement.line, statement.keyword, statement.name)
        multiline_arg = rubify(multiline_arg)
        case(multiline_arg)
        when Gherkin::Formatter::Model::PyString
          @table_owner.multiline_arg = Ast::PyString.new(multiline_arg.value)
        when Array
          @table_owner.multiline_arg = Ast::Table.new(matrix(multiline_arg))
        end
        @step_container.add_step(@table_owner)
      end

      def eof
      end

      def syntax_error(state, event, legal_events, line)
        # raise "SYNTAX ERROR"
      end
      
    private
    
      def legacy_name_for(name, description)
        s = name
        s += "\n#{description}" if description != ""
        s
      end

      def matrix(gherkin_table)
        gherkin_table.map do |gherkin_row|
          row = gherkin_row.cells
          class << row
            attr_accessor :line
          end
          row.line = gherkin_row.line
          row
        end
      end
    end
  end
end
