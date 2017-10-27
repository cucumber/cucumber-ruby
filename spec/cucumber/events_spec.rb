# frozen_string_literal: true

module Cucumber
  describe Events do
    it 'builds a registry without failing' do
      expect { described_class.registry }.not_to raise_error
    end
  end
end
