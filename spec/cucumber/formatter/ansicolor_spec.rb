# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/formatter/ansicolor'

module Cucumber
  module Formatter
    describe ANSIColor do
      include ANSIColor

      it 'wraps passed_param with bold green and reset to green' do
        expect(passed_param('foo')).to eq "\e[32m\e[1mfoo\e[0m\e[0m\e[32m"
      end

      it 'wraps passed in green' do
        expect(passed('foo')).to eq "\e[32mfoo\e[0m"
      end

      it 'does not reset passed if there are no arguments' do
        expect(passed).to eq "\e[32m"
      end

      it 'wraps comments in grey' do
        expect(comment('foo')).to eq "\e[90mfoo\e[0m"
      end

      it 'does not generate ansi codes when colors are disabled' do
        ::Cucumber::Term::ANSIColor.coloring = false

        expect(passed('foo')).to eq 'foo'
      end

      it 'works with a block' do
        expect(passed { 'foo' }).to eq "\e[32mfoo\e[0m"
      end

      context 'with custom color scheme' do
        before do
          ANSIColor.apply_custom_colors('passed=red,bold')
        end

        after do
          reset_colours_to_default
        end

        it 'works with custom colors' do
          expect(passed('foo')).to eq "\e[31m\e[1mfoo\e[0m\e[0m"
        end

        def reset_colours_to_default
          ANSIColor.apply_custom_colors('passed=green')
        end
      end
    end
  end
end
