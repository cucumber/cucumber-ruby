# frozen_string_literal: true

require 'spec_helper'

module Cucumber
  module Cli
    describe RerunFile do
      let(:rerun_file) { described_class.new('@rerun.txt') }

      it 'expects rerun files to have a leading @' do
        allow(File).to receive(:file?).and_return(true)
        expect(described_class.can_read?('rerun.txt')).to eq false
        expect(described_class.can_read?('@rerun.txt')).to eq true
      end

      it 'does not treat directories as rerun files' do
        allow(File).to receive(:file?).and_return(false)
        expect(described_class.can_read?('@rerun.txt')).to eq false
      end

      it 'removes leading @ character from filename' do
        expect(rerun_file.path).to eq 'rerun.txt'
      end

      context 'with a rerun file containing a single feature reference' do
        before(:each) do
          allow(IO).to receive(:read).and_return('cucumber.feature')
        end

        it 'produces an array containing a single feature file path' do
          expect(rerun_file.features).to eq %w[cucumber.feature]
        end
      end

      context 'with a rerun file containing multiple feature references on multiple lines' do
        before(:each) do
          allow(IO).to receive(:read).and_return("cucumber.feature\nfoo.feature")
        end

        it 'produces an array containing multiple feature file paths' do
          expect(rerun_file.features).to eq %w[cucumber.feature foo.feature]
        end
      end

      context 'with a rerun file containing multiple feature references on the same line' do
        before(:each) do
          allow(IO).to receive(:read).and_return('cucumber.feature foo.feature')
        end

        it 'produces an array containing multiple feature file paths' do
          expect(rerun_file.features).to eq %w[cucumber.feature foo.feature]
        end
      end

      context 'with a rerun file containing multiple scenario references on the same line' do
        before(:each) do
          allow(IO).to receive(:read).and_return('cucumber.feature:8 foo.feature:8:16')
        end

        it 'produces an array containing multiple feature file paths with scenario lines' do
          expect(rerun_file.features).to eq %w[cucumber.feature:8 foo.feature:8:16]
        end
      end

      context 'with a rerun file containing multiple feature references with spaces in file names' do
        before(:each) do
          allow(IO).to receive(:read).and_return('cucumber test.feature:8 foo.feature:8:16')
        end

        it 'produces an array containing multiple feature file paths with scenario lines' do
          expect(rerun_file.features).to eq ['cucumber test.feature:8', 'foo.feature:8:16']
        end
      end

      context 'with a rerun file containing multiple scenario references without spaces in between them' do
        before(:each) do
          allow(IO).to receive(:read).and_return('cucumber test.feature:8foo.feature:8:16')
        end

        it 'produces an array containing multiple feature file paths with scenario lines' do
          expect(rerun_file.features).to eq ['cucumber test.feature:8', 'foo.feature:8:16']
        end
      end
    end
  end
end
