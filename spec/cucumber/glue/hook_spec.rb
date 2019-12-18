require 'spec_helper'
require 'cucumber/glue/hook'

module Cucumber
  module Glue
    describe Hook do
      let(:subject) do
        Hook.new('some-id', nil, ['@foo', 'not @bar'], proc { puts 'This is a hook' })
      end

      it 'has a unique ID' do
        expect(subject.id).not_to be_nil
      end

      context('#to_envelope') do
        let(:envelope) { subject.to_envelope }

        it 'produces a Cucumber::Messages::Envelope message' do
          expect(envelope).to be_a(Cucumber::Messages::Envelope)
        end

        it 'fills the hook field of the envelope' do
          expect(envelope.hook).not_to be_nil
        end

        it 'outputs the hook id' do
          expect(envelope.hook.id)
            .to eq(subject.id)
        end

        it 'outputs the tags expressions as string' do
          expect(envelope.hook.tag_expression)
            .to eq('@foo not @bar')
        end

        it 'sets the correct source_reference for the hook' do
          expect(envelope.hook.source_reference.uri)
            .to eq('spec/cucumber/glue/hook_spec.rb')
          expect(envelope.hook.source_reference.location.line)
            .to eq(8)
        end
      end
    end
  end
end
