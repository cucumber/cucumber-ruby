# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/pretty'

module Cucumber
  module Glue
    describe ProtoWorld do
      let(:runtime) { double('runtime') }
      let(:language) { double('language') }
      let(:world) { Object.new.extend(ProtoWorld.for(runtime, language)) }

      describe '#table' do
        it 'produces Ast::Table by #table' do
          expect(world.table(%(
        | account | description | amount |
        | INT-100 | Taxi        | 114    |
        | CUC-101 | Peeler      | 22     |
          ))).to be_kind_of(MultilineArgument::DataTable)
        end
      end

      describe 'Handling logs in step definitions' do
        extend Cucumber::Formatter::SpecHelperDsl
        include Cucumber::Formatter::SpecHelper

        before(:each) do
          Cucumber::Term::ANSIColor.coloring = false
          @out = StringIO.new
          @formatter = Cucumber::Formatter::Pretty.new(actual_runtime.configuration.with_options(out_stream: @out, source: false))
          run_defined_feature
        end

        describe 'when modifying the printed variable after the call to log' do
          define_feature <<-FEATURE
        Feature: Banana party

          Scenario: Monkey eats banana
            When log is called twice for the same variable
          FEATURE

          define_steps do
            When(/^log is called twice for the same variable$/) do
              foo = String.new('a')
              log foo
              foo.upcase!
              log foo
            end
          end

          it 'prints the variable value at the time puts was called' do
            expect(@out.string).to include <<OUTPUT
    When log is called twice for the same variable
      a
      A
OUTPUT
          end
        end

        describe 'when logging an object' do
          define_feature <<-FEATURE
        Feature: Banana party

          Scenario: Monkey eats banana
            When an object is logged
          FEATURE

          define_steps do
            When('an object is logged') do
              log(a: 1, b: 2, c: 3)
            end
          end

          it 'attached the styring version on the object' do
            expect(@out.string).to include '{:a=>1, :b=>2, :c=>3}'
          end
        end

        describe 'when logging multiple items on one call' do
          define_feature <<-FEATURE
        Feature: Banana party

          Scenario: Monkey eats banana
            When monkey eats banana
          FEATURE

          define_steps do
            When('{word} {word} {word}') do |subject, verb, complement|
              log "subject: #{subject}", "verb: #{verb}", "complement: #{complement}", subject: subject, verb: verb, complement: complement
            end
          end

          it 'logs each parameter independently' do
            expect(@out.string).to include [
              '      subject: monkey',
              '      verb: eats',
              '      complement: banana',
              '      {:subject=>"monkey", :verb=>"eats", :complement=>"banana"}'
            ].join("\n")
          end
        end

        describe 'when modifying the printed variable after the call to log' do
          define_feature <<-FEATURE
        Feature: Banana party

          Scenario: Monkey eats banana
            When puts is called twice for the same variable
          FEATURE

          define_steps do
            When(/^puts is called twice for the same variable$/) do
              foo = String.new('a')
              log foo
              foo.upcase!
              log foo
            end
          end

          it 'prints the variable value at the time puts was called' do
            expect(@out.string).to include <<OUTPUT
    When puts is called twice for the same variable
      a
      A
OUTPUT
          end
        end
      end
    end
  end
end
