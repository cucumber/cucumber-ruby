module Cucumber
  module Formatter

    module SpecHelperDsl
      attr_reader :feature_content, :step_defs, :feature_filename

      def define_feature(string, feature_file = 'spec.feature')
        @feature_content = string
        @feature_filename = feature_file
      end

      def define_steps(&block)
        @step_defs = block
      end
    end

    module OldSpecHelper
      def run_defined_feature
        define_steps
        features = load_features(self.class.feature_content || raise("No feature content defined!"))
        run(features)
      end

      def runtime
        @runtime ||= Runtime.new
      end

      def load_features(content)
        feature_file = FeatureFile.new(self.class.feature_filename, content)
        features = Ast::Features.new
        filters = []
        feature = feature_file.parse(filters, {})
        features.add_feature(feature) if feature
        features
      end

      def run(features)
        configuration = Cucumber::Configuration.default
        tree_walker = Cucumber::Ast::TreeWalker.new(runtime, [@formatter], configuration)
        features.accept(tree_walker)
      end

      def define_steps
        return unless step_defs = self.class.step_defs
        rb = runtime.load_programming_language('rb')
        dsl = Object.new
        dsl.extend RbSupport::RbDsl
        dsl.instance_exec &step_defs
      end
    end

    load_path = File.expand_path(File.dirname(__FILE__) + '/../../../../cucumber-ruby-core/lib')
    $: << load_path
    require 'cucumber/core'
    module NewSpecHelper
      include Core

      def run_defined_feature
        #define_steps
        execute [gherkin_doc], mappings, report
        report.after_suite # TODO: move into core
      end

      require 'cucumber/mappings'
      def mappings
        @mappings ||= Mappings.new
      end

      require 'cucumber/formatter/report_adapter'
      def report
        @report ||= Cucumber::Formatter::ReportAdapter.new runtime, @formatter
      end

      require 'cucumber/core/gherkin/document'
      def gherkin_doc
        Core::Gherkin::Document.new(self.class.feature_filename, gherkin)
      end

      def gherkin
        self.class.feature_content || raise("No feature content defined!")
      end

      def runtime
        mappings.runtime
      end

      def define_steps
        return unless step_defs = self.class.step_defs
        rb = runtime.load_programming_language('rb')
        dsl = Object.new
        dsl.extend RbSupport::RbDsl
        dsl.instance_exec &step_defs
      end
    end

    SpecHelper = ENV['USE_LEGACY'] ? OldSpecHelper : NewSpecHelper
  end
end
