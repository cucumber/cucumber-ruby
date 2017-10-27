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
          expect(world.table(%{
        | account | description | amount |
        | INT-100 | Taxi        | 114    |
        | CUC-101 | Peeler      | 22     |
          })).to be_kind_of(MultilineArgument::DataTable)
        end
      end

      describe 'Handling puts in step definitions' do
        extend Cucumber::Formatter::SpecHelperDsl
        include Cucumber::Formatter::SpecHelper

        before(:each) do
          Cucumber::Term::ANSIColor.coloring = false
          @out = StringIO.new
          @formatter = Cucumber::Formatter::Pretty.new(runtime, @out, {})
          run_defined_feature
        end

        describe 'when modifying the printed variable after the call to puts' do
          define_feature <<-FEATURE
        Feature: Banana party

          Scenario: Monkey eats banana
            When puts is called twice for the same variable
          FEATURE

          define_steps do
            When(/^puts is called twice for the same variable$/) do
              foo = String.new('a')
              puts foo
              foo.upcase!
              puts foo
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
