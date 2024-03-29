# frozen_string_literal: true

require 'cucumber/running_test_case'
require 'cucumber/core'
require 'cucumber/core/gherkin/writer'

module Cucumber
  describe RunningTestCase do
    include Core
    include Core::Gherkin::Writer

    attr_accessor :wrapped_test_case, :core_test_case

    let(:result) { double(:result, to_sym: :status_symbol) }

    before do
      receiver = double.as_null_object
      allow(receiver).to receive(:test_case) { |core_test_case|
        self.core_test_case = core_test_case
        self.wrapped_test_case = described_class.new(core_test_case).with_result(result)
      }
      compile [gherkin_doc], receiver
    end

    context 'with a regular scenario' do
      let(:gherkin_doc) do
        gherkin do
          feature 'feature name' do
            scenario 'scenario name' do
              step 'passing'
            end
          end
        end
      end

      it 'sets the scenario name correctly' do
        expect(wrapped_test_case.name).to eq 'scenario name'
      end

      it 'exposes properties of the test_case' do
        expect(wrapped_test_case.location).to eq core_test_case.location
        expect(wrapped_test_case.language).to eq core_test_case.language
      end

      it 'exposes properties of the result' do
        expect(wrapped_test_case.status).to eq result.to_sym
      end
    end

    context 'with a failing scenario' do
      let(:gherkin_doc) do
        gherkin do
          feature 'feature name' do
            scenario 'scenario name' do
              step 'failed'
            end
          end
        end
      end

      let(:exception) { StandardError.new }

      before do
        self.wrapped_test_case = wrapped_test_case.with_result(Core::Test::Result::Failed.new(0, exception))
      end

      it 'is failed?' do
        expect(wrapped_test_case).to be_failed
      end

      it 'exposes the exception' do
        expect(wrapped_test_case.exception).to eq exception
      end
    end

    context 'with a passing scenario' do
      let(:gherkin_doc) do
        gherkin do
          feature 'feature name' do
            scenario 'scenario name' do
              step 'passing'
            end
          end
        end
      end

      before do
        self.wrapped_test_case = wrapped_test_case.with_result(Core::Test::Result::Passed.new(0))
      end

      it 'is not failed?' do
        expect(wrapped_test_case).not_to be_failed
      end

      it '#exception is nil' do
        expect(wrapped_test_case.exception).to be_nil
      end
    end

    context 'when using a scenario outline' do
      let(:gherkin_doc) do
        gherkin do
          feature 'feature name' do
            scenario_outline 'scenario outline name' do
              step 'passing with <arg1> <arg2>'

              examples 'examples name' do
                row 'arg1', 'arg2'
                row 'a', 'b'
              end
            end
          end
        end
      end

      it "sets the test case's name correctly" do
        expect(wrapped_test_case.name).to eq('scenario outline name')
      end

      it 'exposes properties of the test_case' do
        expect(wrapped_test_case.location).to eq(core_test_case.location)
        expect(wrapped_test_case.language).to eq(core_test_case.language)
      end
    end
  end
end
