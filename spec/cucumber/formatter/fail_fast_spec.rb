require 'cucumber/formatter/fail_fast'
require 'cucumber/core'
require 'cucumber/core/gherkin/writer'
require 'cucumber/core/test/result'
require 'cucumber/core/filter'
require 'cucumber/core/ast'
require 'cucumber'
require 'support/standard_step_actions'

module Cucumber::Formatter
  describe FailFast do 
    include Cucumber::Core
    include Cucumber::Core::Gherkin::Writer

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
        execute([@gherkin], report, [StandardStepActions.new])
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
        execute([@gherkin], report, [StandardStepActions.new])
        expect(Cucumber.wants_to_quit).to be_falsey
      end
    end

  end
end
