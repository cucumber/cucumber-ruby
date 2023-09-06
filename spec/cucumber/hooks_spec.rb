# frozen_string_literal: true

require 'cucumber/hooks'
module Cucumber
  module Hooks
    shared_examples_for 'a source node' do
      it 'responds to text' do
        expect(subject.text).to be_a(String)
      end

      it 'responds to location' do
        expect(subject.location).to eq(location)
      end

      it 'responds to match_locations?' do
        expect(subject).to be_match_locations([location])
        expect(subject).not_to be_match_locations([])
      end
    end

    require 'cucumber/core/test/location'
    describe BeforeHook do
      subject { described_class.new(location) }
      let(:location) { Cucumber::Core::Test::Location.new('hooks.rb', 1) }
      it_behaves_like 'a source node'
    end

    describe AfterHook do
      subject { described_class.new(location) }
      let(:location) { Cucumber::Core::Test::Location.new('hooks.rb', 1) }
      it_behaves_like 'a source node'
    end
  end
end
