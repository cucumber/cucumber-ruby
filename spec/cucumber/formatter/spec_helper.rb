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

    require 'cucumber/core'
    module SpecHelper
      include Core

      def run_defined_feature
        define_steps
        runtime.visitor = report
        execute [gherkin_doc], mappings, report
      end

      require 'cucumber/mappings'
      def mappings
        @mappings ||= Mappings.new
      end

      require 'cucumber/reports'
      def report
        @report ||= Reports::FanOut.new([
          Reports::LegacyFormatter.new(runtime, @formatter),
          Reports::LegacyResultRecorder.new(runtime)
        ])
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

  end
end
