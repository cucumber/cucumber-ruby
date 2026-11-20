# frozen_string_literal: true

require 'cucumber/configuration'
require 'cucumber/formatter/console'
require 'cucumber/step_match'

module Cucumber
  module Formatter
    RSpec.describe Console do
      include described_class
      it 'indents when padding is positive' do
        res = indent('a line', 2)
        expect(res).to eq '  a line'
      end

      it 'indents when padding is negative' do
        res = indent('  a line', -1)
        expect(res).to eq ' a line'
      end

      it 'handles excessive negative indentation properly' do
        res = indent('  a line', -10)
        expect(res).to eq 'a line'
      end

      context 'when coloring console output' do
        around do |example|
          original_coloring = Cucumber::Term::ANSIColor.coloring?
          Cucumber::Term::ANSIColor.coloring = true
          example.run
        ensure
          Cucumber::Term::ANSIColor.coloring = original_coloring
        end

        it 'uses color by default when the formatter output is a tty' do
          @io = instance_double(IO, tty?: true)
          @options = {}

          expect(format_string('undefined', :undefined)).to include("\e[33m")
        end

        it 'disables color by default when the formatter output is a file' do
          @io = instance_double(File, tty?: false)
          @options = {}

          expect(format_string('undefined', :undefined)).to eq 'undefined'
        end

        it 'allows explicit color to override the formatter output destination' do
          @io = instance_double(File, tty?: false)
          @options = { color: true }

          expect(format_string('undefined', :undefined)).to include("\e[33m")
        end

        it 'allows explicit no-color to override a tty output destination' do
          @io = instance_double(IO, tty?: true)
          @options = { color: false }

          expect(format_string('undefined', :undefined)).to eq 'undefined'
        end

        it 'disables step argument color by default when the formatter output is a file' do
          @io = instance_double(File, tty?: false)
          @options = {}
          step_match = instance_double(Cucumber::StepMatch)
          allow(step_match).to receive(:format_args) { |format| "I have #{format.call('3')} cukes" }

          expect(format_step('Given ', step_match, :passed, nil)).to eq 'Given I have 3 cukes'
        end
      end
    end
  end
end
