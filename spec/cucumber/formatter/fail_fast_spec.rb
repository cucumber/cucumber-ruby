require 'cucumber/formatter/fail_fast'
require 'cucumber/core'
require 'cucumber/core/gherkin/writer'
require 'cucumber/core/test/result'
require 'cucumber/core/filter'
require 'cucumber/core/ast'
require 'cucumber'

module Cucumber::Formatter
  describe FailFast do 
    include Cucumber::Core
    include Cucumber::Core::Gherkin::Writer

    class WithStepsFake < Cucumber::Core::Filter.new
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

    let(:configuration) { Cucumber::Configuration.new }
    before { FailFast.new(configuration) }
    let(:report) { EventBusReport.new(configuration) }

    context 'failing scenario' do 
      before(:each) do 
        @gherkin = gherkin('foo.feature') do 
          feature do 
            scenario do 
              step 'failing'
            end

            scenario do 
              step 'failing'
            end
          end
        end
      end

      after(:each) do 
        Cucumber.wants_to_quit = false
      end

      it 'sets Cucumber.wants_to_quit' do 
        execute([@gherkin], report, [WithStepsFake.new])
        expect(Cucumber.wants_to_quit).to be true
      end
    end

    context 'passing scenario' do 
      before(:each) do 
        @gherkin = gherkin('foo.feature') do 
          feature do 
            scenario do 
              step 'passing'
            end
          end
        end
      end

      it 'doesn\'t set Cucumber.wants_to_quit' do 
        execute([@gherkin], report, [WithStepsFake.new])
        expect(Cucumber.wants_to_quit).to be_falsey
      end
    end

  end
end
