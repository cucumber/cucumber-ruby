# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/message'
require 'cucumber/cli/options'

module Cucumber
  module Formatter
    describe Message do
      extend SpecHelperDsl
      include SpecHelper

      before(:each) do
        Cucumber::Term::ANSIColor.coloring = false
        @out = StringIO.new
        @formatter = Message.new(actual_runtime.configuration.with_options(out_stream: @out))
      end

      describe 'given a single feature' do
        before(:each) do
          run_defined_feature
        end

        describe 'with a scenario' do
          define_feature <<-FEATURE
            Feature: Banana party

              Scenario: Monkey eats banana
                Given there are bananas
          FEATURE

          it 'outputs the undefined step' do
            expect(@out.string).to include '"status":"UNDEFINED"'
          end
        end
      end
    end
  end
end
