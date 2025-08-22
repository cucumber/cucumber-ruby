# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/pretty'
require 'cucumber/formatter/message'

module Cucumber
  module Glue
    describe ProtoWorld do
      let(:runtime) { double('runtime') }
      let(:language) { double('language') }
      let(:world) { Object.new.extend(described_class.for(runtime, language)) }

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

        describe 'when modifying the printed variable after the call to #log' do
          define_feature <<~FEATURE
            Feature: Banana party
    
              Scenario: Monkey eats banana
                When log is called twice for the same variable
          FEATURE

          define_steps do
            When('log is called twice for the same variable') do
              foo = String.new('a')
              log foo
              foo.upcase!
              log foo
            end
          end

          it 'prints the variable value at the time `#log` was called' do
            expect(@out.string).to include <<~OUTPUT
              When log is called twice for the same variable
                    a
                    A
            OUTPUT
          end
        end

        describe 'when logging an object' do
          define_feature <<~FEATURE
            Feature: Banana party

              Scenario: Monkey eats banana
                When an object is logged
          FEATURE

          define_steps do
            When('an object is logged') do
              object = Object.new
              def object.to_s
                '<test-object>'
              end
              log(object)
            end
          end

          it 'prints the stringified version of the object as a log message' do
            expect(@out.string).to include('<test-object>')
          end
        end

        describe 'when logging multiple items on one call' do
          define_feature <<~FEATURE
            Feature: Logging multiple entries
    
              Scenario: Logging multiple entries
                When logging multiple entries
          FEATURE

          define_steps do
            When('logging multiple entries') do
              log 'entry one', 'entry two', 'entry three'
            end
          end

          it 'logs each entry independently' do
            expect(@out.string).to include([
              '      entry one',
              '      entry two',
              '      entry three'
            ].join("\n"))
          end
        end
      end

      describe 'Handling attachments in step definitions' do
        extend Cucumber::Formatter::SpecHelperDsl
        include Cucumber::Formatter::SpecHelper

        before do
          Cucumber::Term::ANSIColor.coloring = false
          @out = StringIO.new
          @formatter = Cucumber::Formatter::Pretty.new(actual_runtime.configuration.with_options(out_stream: @out, source: false))
          run_defined_feature
        end

        context 'when attaching data with null byte' do
          define_feature <<~FEATURE
            Feature: Banana party

              Scenario: Monkey eats banana
                When some data is attached
          FEATURE

          define_steps do
            When('some data is attached') do
              attach("'\x00'attachment", 'text/x.cucumber.log+plain')
            end
          end

          it 'does not report an error' do
            expect(@out.string).not_to include('Error')
          end

          it 'properly attaches the data' do
            expect(@out.string).to include("'\x00'attachment")
          end
        end

        context 'when attaching a image using a file path' do
          define_feature <<~FEATURE
            Feature: Banana party

              Scenario: Monkey eats banana
                When some data is attached
          FEATURE

          define_steps do
            When('some data is attached') do
              path = "#{Dir.pwd}/docs/img/cucumber-open-logo.png"
              attach(path, 'image/png')
            end
          end

          it 'does not report an error' do
            expect(@out.string).not_to include('Error')
          end

          it 'properly attaches the image' do
            pending 'This is correct currently with the pretty implementation'

            expect(@out.string).to include("'\x00'attachment")
          end
        end

        context 'when attaching a image using the input-read data' do
          define_feature <<~FEATURE
            Feature: Banana party

              Scenario: Monkey eats banana
                When some data is attached
          FEATURE

          define_steps do
            When('some data is attached') do
              path = "#{Dir.pwd}/docs/img/cucumber-open-logo.png"
              image_data = File.read(path, mode: 'rb')
              attach(image_data, 'base64;image/png')
            end
          end

          it 'does not report an error' do
            expect(@out.string).not_to include('Error')
          end

          it 'properly attaches the image' do
            pending 'This is correct currently with the pretty implementation'

            expect(@out.string).to include("'\x00'attachment")
          end
        end
      end
    end
  end
end
