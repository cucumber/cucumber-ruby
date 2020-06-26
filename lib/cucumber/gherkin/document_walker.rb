module Cucumber
  module Gherkin
    class DocumentWalker
      def initialize(node_handler = AstNodeHandler.new)
        @node_handler = node_handler
        @node_path = []
      end

      def walk_gherkin_document(gherkin_document)
        @node_path << gherkin_document
        @node_handler.handle_gherkin_document(gherkin_document, @node_path)

        walk_feature(gherkin_document.feature) unless gherkin_document.feature.nil?
        @node_path.pop
      end

      private

      def walk_feature(feature)
        @node_path << feature
        @node_handler.handle_feature(feature, @node_path)

        feature.children.each do |child|
          walk_rule(child.rule) if child.rule
          walk_background(child.background) if child.background
          walk_scenario(child.scenario) if child.scenario
        end
        @node_path.pop
      end

      def walk_rule(rule)
        @node_path << rule
        @node_handler.handle_rule(rule, @node_path)

        rule.children.each do |child|
          walk_background(child.background) if child.background
          walk_scenario(child.scenario) if child.scenario
        end
        @node_path.pop
      end

      def walk_background(background)
        @node_path << background
        @node_handler.handle_background(background, @node_path)

        background.steps.each do |step|
          walk_step(step)
        end
        @node_path.pop
      end

      def walk_scenario(scenario)
        @node_path << scenario
        @node_handler.handle_scenario(scenario, @node_path)

        scenario.steps.each do |step|
          walk_step(step)
        end

        scenario.examples.each do |examples|
          walk_examples(examples)
        end
        @node_path.pop
      end

      def walk_step(step)
        @node_path << step
        @node_handler.handle_step(step, @node_path)
        @node_path.pop
      end

      def walk_examples(examples)
        @node_path << examples
        @node_handler.handle_examples(examples, @node_path)

        examples.table_body.each do |row|
          walk_example_row(row)
        end
        @node_path.pop
      end

      def walk_example_row(row)
        @node_path << row
        @node_handler.handle_example_row(row, @node_path)
        @node_path.pop
      end
    end

    class AstNodeHandler
      def handle_gherkin_document(gherkin_document, node_path); end

      def handle_feature(feature, node_path); end

      def handle_rule(rule, node_path); end

      def handle_background(background, node_path); end

      def handle_scenario(scenario, node_path); end

      def handle_step(step, node_path); end

      def handle_examples(examples, node_path); end

      def handle_example_row(example_row, node_path); end
    end
  end
end
