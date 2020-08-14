# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/publish_banner_printer'

module Cucumber
  module Formatter
    describe PublishBannerPrinter do
      extend SpecHelperDsl
      include SpecHelper

      before do
        Cucumber::Term::ANSIColor.coloring = false
        @err = StringIO.new
        @formatter = PublishBannerPrinter.new(actual_runtime.configuration.with_options(error_stream: @err))
      end

      context 'passing scenario' do
        define_feature <<-FEATURE
      Feature: Banana party
        FEATURE

        it 'prints banner' do
          run_defined_feature
          expect(@err.string).to include(<<~BANNER)
            ┌──────────────────────────────────────────────────────────────────────────┐
            │ Share your Cucumber Report with your team at https://reports.cucumber.io │
            │                                                                          │
            │ Command line option:    --publish                                        │
            │ Environment variable:   CUCUMBER_PUBLISH_ENABLED=true                    │
            │                                                                          │
            │ More information at https://reports.cucumber.io/docs/cucumber-ruby       │
            │                                                                          │
            │ To disable this message, specify CUCUMBER_PUBLISH_QUIET=true or use the  │
            │ --publish-quiet option. You can also add this to your cucumber.yml:      │
            │ default: --publish-quiet                                                 │
            └──────────────────────────────────────────────────────────────────────────┘
          BANNER
        end
      end
    end
  end
end
