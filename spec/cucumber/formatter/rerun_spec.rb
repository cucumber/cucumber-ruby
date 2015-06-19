require 'cucumber/formatter/rerun'
require 'cucumber/core'
require 'cucumber/core/gherkin/writer'
require 'cucumber/core/filter'

module Cucumber::Formatter
  describe Rerun do
    include Cucumber::Core::Gherkin::Writer
    include Cucumber::Core

    # after_test_case
    context 'when 2 scenarios fail in the same file' do
      class WithSteps < Cucumber::Core::Filter.new
        def test_case(test_case)
          test_steps = test_case.test_steps.map do |step|
            case step.name
            when /fail/
              step.with_action { raise Failure }
            when /pass/
              step.with_action {}
            else
              step
            end
          end

          test_case.with_steps(test_steps).describe_to(receiver)
        end
      end

      it 'Prints the locations of the failed scenarios' do
        gherkin = gherkin('foo.feature') do
          feature do
            scenario do
              step 'failing'
            end

            scenario do
              step 'failing'
            end

            scenario do
              step 'passing'
            end
          end
        end
        io = StringIO.new
        report = Rerun.new(double, io, {})

        execute [gherkin], report, [WithSteps.new]

        expect( io.string ).to eq 'foo.feature:3:6'
      end
    end

    context 'with failures in multiple files' do
      it 'prints the location of the failed scenarios in each file' do
        foo = gherkin('foo.feature') do
          feature do
            scenario do
              step 'failing'
            end

            scenario do
              step 'failing'
            end

            scenario do
              step 'passing'
            end
          end
        end

        bar = gherkin('bar.feature') do
          feature do
            scenario do
              step 'failing'
            end
          end
        end

        io = StringIO.new
        report = Rerun.new(double, io, {})

        execute [foo, bar], report, [WithSteps.new]

        expect(io.string).to eq 'foo.feature:3:6 bar.feature:3'
      end
    end

    context 'when there are no failing scenarios' do
      it 'prints nothing' do
        gherkin = gherkin('foo.feature') do
          feature do
            scenario do
              step 'passing'
            end
          end
        end

        io = StringIO.new
        report = Rerun.new(double, io, {})

        execute [gherkin], report, [WithSteps.new]
      end
    end
  end
end
