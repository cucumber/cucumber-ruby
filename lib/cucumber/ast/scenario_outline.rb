require 'cucumber/ast/has_steps'
require 'cucumber/ast/names'
require 'cucumber/ast/empty_background'

module Cucumber
  module Ast
    class ScenarioOutline #:nodoc:
      include HasSteps
      include Names
      include HasLocation

      attr_accessor :feature
      attr_reader :feature_tags

      module ExamplesArray #:nodoc:
        def accept(visitor)
          return if Cucumber.wants_to_quit
          each do |examples|
            visitor.visit_examples(examples)
          end
        end
      end

      # The +example_sections+ argument must be an Array where each element is another array representing
      # an Examples section. This array has 3 elements:
      #
      # * Examples keyword
      # * Examples section name
      # * Raw matrix
      def initialize(language, location, background, comment, tags, feature_tags, keyword, title, description, raw_steps, example_sections)
        @language, @location, @background, @comment, @tags, @feature_tags, @keyword, @title, @description, @raw_steps, @example_sections = language, location, background, comment, tags, feature_tags, keyword, title, description, raw_steps, example_sections
        attach_steps(@raw_steps)
      end

      def accept(visitor)
        return if Cucumber.wants_to_quit
        raise_missing_examples_error unless @example_sections

        visitor.visit_comment(@comment) unless @comment.empty?
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@keyword, name, file_colon_line, source_indent(first_line_length))
        visitor.visit_steps(steps)

        skip_invoke! if @background.failed?
        visitor.visit_examples_array(examples_array) unless examples_array.empty?
      end

      def to_units(background)
        raise ArgumentError.new("#{background} != #{@background}") unless background == @background # maybe we don't need this argument, but it seems like the leaf AST nodes would be better not being aware of their parents. However step_invocations uses the ivar at the moment, so we'll just do this check to make sure its OK.
        result = []
        each_example_row do |row|
          result << Unit.new(step_invocations(row))
        end
        result
      end

      def fail!(exception)
        # Just a hack for https://rspec.lighthouseapp.com/projects/16211/tickets/413-scenario-outlines-that-fail-with-exception-exit-process
        # Also see http://groups.google.com/group/cukes/browse_thread/thread/41cd567cb9df4bc3
      end

      def skip_invoke!
        examples_array.each { |examples| examples.skip_invoke! }
      end

      def step_invocations(cells)
        step_invocations = steps.step_invocations_from_cells(cells)
        if @background
          @background.step_collection(step_invocations)
        else
          StepCollection.new(step_invocations)
        end
      end

      def each_example_row(&proc)
        examples_array.each do |examples|
          examples.each_example_row(&proc)
        end
      end

      def visit_scenario_name(visitor, row)
        visitor.visit_scenario_name(
          language.keywords('scenario')[0],
          row.name,
          Location.new(file, row.line).to_s,
          source_indent(first_line_length)
        )
      end

      def failed?
        examples_array.select { |examples| examples.failed? }.any?
      end

      def to_sexp
        sexp = [:scenario_outline, @keyword, name]
        comment = @comment.to_sexp
        sexp += [comment] if comment
        tags = @tags.to_sexp
        sexp += tags if tags.any?
        sexp += steps.to_sexp if steps.any?
        sexp += examples_array.map{|e| e.to_sexp}
        sexp
      end

      private

      attr_reader :line

      def examples_array
        return @examples_array if @examples_array
        @examples_array = @example_sections.map do |section|
          create_examples_table(section)
        end
        @examples_array.extend(ExamplesArray)
        @examples_array
      end

      def create_examples_table(example_section_and_gherkin_examples)
        example_section = example_section_and_gherkin_examples[0]
        gherkin_examples = example_section_and_gherkin_examples[1]

        examples_location    = example_section[0]
        examples_comment     = example_section[1]
        examples_keyword     = example_section[2]
        examples_title       = example_section[3]
        examples_description = example_section[4]
        examples_matrix      = example_section[5]

        examples_table = OutlineTable.new(examples_matrix, self)
        ex = Examples.new(examples_location, examples_comment, examples_keyword, examples_title, examples_description, examples_table)
        ex.gherkin_statement(gherkin_examples)
        ex
      end

      def steps
        @steps ||= StepCollection.new(@raw_steps)
      end

      def raise_missing_examples_error
        raise MissingExamples, "Missing Example Section for Scenario Outline at #{@location}"
      end

      MissingExamples = Class.new(StandardError)
    end
  end
end
