require 'spec_helper'
require 'cucumber/glue/hook'

module Cucumber
  module Glue
    describe Hook do
      let(:subject) {
        Hook.new(nil, ['@foo', 'not @bar'], Proc.new {puts "This is a hook"})
      }
      context('#to_envelope') do
        let(:envelope) { subject.to_envelope }

        it 'produces a Cucumber::Messages::Envelope message' do
          expect(envelope).to be_a(Cucumber::Messages::Envelope)
        end

        it 'fills the testCaseHookDefinitionConfig field of the envelope' do
          expect(envelope.testCaseHookDefinitionConfig).not_to be_nil
        end

        it 'adds the tags expressions as string' do
          expect(envelope.testCaseHookDefinitionConfig.tagExpression)
            .to eq("@foo not @bar")
        end

        it 'sets the correct location for the hook' do
          expect(envelope.testCaseHookDefinitionConfig.location.uri)
            .to eq('spec/cucumber/glue/hook_spec.rb')
          expect(envelope.testCaseHookDefinitionConfig.location.location.line)
            .to eq(8)
        end
      end
    end
  end
end