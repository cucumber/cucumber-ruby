# frozen_string_literal: true
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
        actual_runtime.visitor = report

        receiver = Test::Runner.new(event_bus)
        filters = [
          Filters::ActivateSteps.new(
            StepMatchSearch.new(actual_runtime.support_code.registry.method(:step_matches), actual_runtime.configuration),
            actual_runtime.configuration
          ),
          Filters::ApplyAfterStepHooks.new(actual_runtime.support_code),
          Filters::ApplyBeforeHooks.new(actual_runtime.support_code),
          Filters::ApplyAfterHooks.new(actual_runtime.support_code),
          Filters::ApplyAroundHooks.new(actual_runtime.support_code),
          Filters::PrepareWorld.new(actual_runtime)
        ]
        compile [gherkin_doc], receiver, filters
        event_bus.test_run_finished
      end

      require 'cucumber/formatter/legacy_api/adapter'
      def report
        @report ||= LegacyApi::Adapter.new(
          Fanout.new([@formatter]),
          actual_runtime.results,
          actual_runtime.configuration)
      end

      require 'cucumber/core/gherkin/document'
      def gherkin_doc
        Core::Gherkin::Document.new(self.class.feature_filename, gherkin)
      end

      def gherkin
        self.class.feature_content || raise('No feature content defined!')
      end

      def runtime
        @runtime_facade ||= LegacyApi::RuntimeFacade.new(actual_runtime.results, actual_runtime.support_code, actual_runtime.configuration)
      end

      def actual_runtime
        @runtime ||= Runtime.new(options)
      end

      def event_bus
        actual_runtime.configuration.event_bus
      end

      def define_steps
        step_defs = self.class.step_defs

        return unless step_defs
        dsl = Object.new
        dsl.extend Glue::Dsl
        dsl.instance_exec &step_defs
      end

      def options
        {}
      end
    end
  end
end
