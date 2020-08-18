# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/html'
require 'cucumber/cli/options'

module Cucumber
  module Formatter
    describe HTML do
      extend SpecHelperDsl
      include SpecHelper

      before(:each) do
        @out = StringIO.new
        @formatter = HTML.new(actual_runtime.configuration.with_options(out_stream: @out, source: false))
      end

      describe 'with a scenario' do
        define_feature <<-FEATURE
          Feature: Banana party

            Scenario: Monkey eats banana
              Given there are bananas
        FEATURE

        before(:each) do
          run_defined_feature
        end

        it 'outputs html' do
          expect(@out.string).to include '<!DOCTYPE html>'
        end

        it 'closes the html tag' do
          expect(@out.string).to include '</html>'
        end

        it 'closes the stream' do
          expect(@out).to be_closed
        end
      end
    end
  end
end
