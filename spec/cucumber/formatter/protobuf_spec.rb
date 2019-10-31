# frozen_string_literal: true

require 'spec_helper'

require 'cucumber/formatter/protobuf'

module Cucumber
  module Formatter
    describe Protobuf do
    end

    describe EventToProtobuf do
      context '.test_step_finished' do
        let(:event) {
          Cucumber::Events::TestStepFinished.new(
            Cucumber::Core::Test::Step.new("some text", "my_feature:31"),
            Cucumber::Core::Test::Result::Passed.new(123456)
          )
        }

        it 'takes a Cucumber::Events::TestStepFinished and returns a Cucumber::Messages::TestStepFinished' do
          expect(EventToProtobuf.test_step_finished(event)).to be_an_instance_of?(Cucumber::Messages::TestStepFinished)
        end
      end

      context '.test_case_finished' do
      end

      context '.nanos_to_duration' do
        it 'converts nanos seconds to Cucumber::Messages::Duration' do
          msg = EventToProtobuf.nanos_to_duration(1234567899)
          expect(msg.seconds).to eq(1)
          expect(msg.nanos).to eq(234567899)
        end
      end
    end
  end
end