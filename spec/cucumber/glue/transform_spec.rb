# frozen_string_literal: true
require 'spec_helper'
require 'cucumber/glue/transform'

module Cucumber
  module Glue
    describe Transform do
      def transform(regexp)
        Transform.new(nil, regexp, -> (a) { })
      end

      describe '#to_s' do
        it 'does not touch positive lookahead captures' do
          expect(transform(/^xy(?=z)/).to_s).to eq 'xy(?=z)'
        end

        it 'does not touch negative lookahead captures' do
          expect(transform(/^xy(?!z)/).to_s).to eq 'xy(?!z)'
        end

        it 'does not touch positive lookbehind captures' do
          expect(transform(/^xy(?<=z)/).to_s).to eq 'xy(?<=z)'
        end

        it 'does not touch negative lookbehind captures' do
          expect(transform(/^xy(?<!z)/).to_s).to eq 'xy(?<!z)'
        end

        it 'converts named captures' do
          expect(transform(/^(?<str>xyz)/).to_s).to eq '(?:<str>xyz)'
        end

        it 'converts captures groups to non-capture groups' do
          expect(transform(/(a|b)bc/).to_s).to eq '(?:a|b)bc'
        end

        it 'leaves non capture groups alone' do
          expect(transform(/(?:a|b)bc/).to_s).to eq '(?:a|b)bc'
        end

        it 'strips away anchors' do
          expect(transform(/^xyz$/).to_s).to eq 'xyz'
        end
      end
    end
  end
end
