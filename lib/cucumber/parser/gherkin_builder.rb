require 'cucumber/ast'

module Cucumber
  module Parser
    # This class conforms to the Gherkin event API and builds the
    # "legacy" AST. It will be replaced later when we have a new "clean"
    # AST.
    class GherkinBuilder

      def ast
        @feature || @multiline_arg
      end

      def feature(comments, tags, keyword, name, description, uri)
        @feature = Ast::Feature.new(
          nil, 
          Ast::Comment.new(comments.join("\n")), 
          Ast::Tags.new(nil, tags),
          keyword,
          legacy_name_for(name, description),
          []
        )
      end

      def background(comments, keyword, name, description, line)
        @background = Ast::Background.new(
          Ast::Comment.new(comments.join("\n")), 
          line, 
          keyword, 
          legacy_name_for(name, description), 
          steps=[]
        )
        @feature.background = @background
        @background.feature = @feature
        @step_container = @background
      end

      def scenario(comments, tags, keyword, name, description, line)
        scenario = Ast::Scenario.new(
          @background, 
          Ast::Comment.new(comments.join("\n")), 
          Ast::Tags.new(nil, tags), 
          line, 
          keyword, 
          legacy_name_for(name, description), 
          steps=[]
        )
        @feature.add_feature_element(scenario)
        @background.feature_elements << scenario if @background
        @step_container = scenario
      end

      def scenario_outline(comments, tags, keyword, name, description, line)
        scenario_outline = Ast::ScenarioOutline.new(
          @background, 
          Ast::Comment.new(comments.join("\n")), 
          Ast::Tags.new(nil, tags), 
          line, 
          keyword, 
          legacy_name_for(name, description), 
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

      def examples(comments, tags, keyword, name, description, line, examples_table)
        examples_fields = [Ast::Comment.new(comments.join("\n")), line, keyword, legacy_name_for(name, description), matrix(examples_table)]
        @step_container.add_examples(examples_fields)
      end

      def step(comments, keyword, name, line, multiline_arg, status, exception, arguments, stepdef_location)
        @table_owner = Ast::Step.new(line, keyword, name)
        case(multiline_arg)
        when String
          @table_owner.multiline_arg = Ast::PyString.new(multiline_arg)
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
