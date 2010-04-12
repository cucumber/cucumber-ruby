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

      def tag(name, line)
        @tags ||= []
        @tags << name
      end

      def comment(content, line)
        @comments ||= []
        @comments << content
      end

      def feature(keyword, name, line)
        @feature = Ast::Feature.new(
          nil, 
          Ast::Comment.new(grab_comments!('')), 
          Ast::Tags.new(nil, grab_tags!('')),
          keyword,
          name,
          []
        )
      end

      def background(keyword, name, line)
        @background = Ast::Background.new(
          Ast::Comment.new(grab_comments!('')), 
          line, 
          keyword, 
          name, 
          steps=[]
        )
        @feature.background = @background
        @background.feature = @feature
        @step_container = @background
      end

      def scenario(keyword, name, line)
        grab_table!
        scenario = Ast::Scenario.new(
          @background, 
          Ast::Comment.new(grab_comments!('')), 
          Ast::Tags.new(nil, grab_tags!('')), 
          line, 
          keyword, 
          name, 
          steps=[]
        )
        @feature.add_feature_element(scenario)
        @background.feature_elements << scenario if @background
        @step_container = scenario
      end

      def scenario_outline(keyword, name, line)
        grab_table!
        scenario_outline = Ast::ScenarioOutline.new(
          @background, 
          Ast::Comment.new(grab_comments!('')), 
          Ast::Tags.new(nil, grab_tags!('')), 
          line, 
          keyword, 
          name, 
          steps=[],
          example_sections=[]
        )
        @feature.add_feature_element(scenario_outline)
        @background.feature_elements << scenario_outline if @background
        @step_container = scenario_outline
      end

      def examples(keyword, name, line)
        grab_table!
        @examples_fields = [Ast::Comment.new(grab_comments!('')), line, keyword, name]
      end

      def step(keyword, name, line)
        grab_table!
        @table_owner = Ast::Step.new(line, keyword, name)
        @step_container.add_step(@table_owner)
      end

      def row(row, line)
        @rows ||= []
        @rows << row
      end

      def py_string(string, line)
        @multiline_arg = Ast::PyString.new(string)
        @table_owner.multiline_arg = @multiline_arg if @table_owner
      end

      def eof
        grab_table!
      end

      def syntax_error(state, event, legal_events, line)
        # raise "SYNTAX ERROR"
      end

    private

      def grab_table!
        return if @rows.nil? 
        if @examples_fields
          @examples_fields << @rows
          @step_container.add_examples(@examples_fields)
          @examples_fields = nil
        else
          @multiline_arg = Ast::Table.new(@rows)
          @table_owner.multiline_arg = @multiline_arg if @table_owner
        end
        @rows = nil
      end

      def grab_tags!(indent)
        tags = @tags ? @tags : []
        @tags = nil
        tags
      end

      def grab_comments!(indent)
        comments = @comments ? indent + @comments.join("\n#{indent}") : ''
        @comments = nil
        comments
      end
    end
  end
end