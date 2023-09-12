# frozen_string_literal: true

require 'cucumber/step_match_search'
require 'cucumber/glue/dsl'
require 'cucumber/glue/registry_and_more'
require 'cucumber/configuration'

module Cucumber
  describe StepMatchSearch do
    let(:search) { described_class.new(registry.method(:step_matches), configuration) }
    let(:registry) { Glue::RegistryAndMore.new(runtime, configuration) }
    let(:configuration) { Configuration.new(options) }
    let(:options) { {} }
    let(:dsl) do
      # TODO: stop relying on implicit global state
      registry
      Object.new.extend(Glue::Dsl)
    end

    it 'caches step match results' do
      dsl.Given(/it (.*) in (.*)/) { |what, month| }

      step_match = search.call('it snows in april').first

      expect(registry).not_to receive(:step_matches)
      second_step_match = search.call('it snows in april').first

      expect(step_match).to equal(second_step_match)
    end

    describe 'resolving step definition matches' do
      let(:elongated_error_message) do
        %{Ambiguous match of "Three blind mice":

spec/cucumber/step_match_search_spec.rb:\\d+:in `/Three (.*) mice/'
spec/cucumber/step_match_search_spec.rb:\\d+:in `/Three blind (.*)/'

You can run again with --guess to make Cucumber be more smart about it
}
      end

      it 'raises Ambiguous error with guess hint when multiple step definitions match' do
        dsl.Given(/Three (.*) mice/) { |disability| }
        dsl.Given(/Three blind (.*)/) { |animal| }

        expect { search.call('Three blind mice').first }.to raise_error(Ambiguous, /#{elongated_error_message}/)
      end

      describe 'when --guess is used' do
        let(:options) { { guess: true } }
        let(:elongated_error_message) do
          %{Ambiguous match of "Three cute mice":

spec/cucumber/step_match_search_spec.rb:\\d+:in `/Three (.*) mice/'
spec/cucumber/step_match_search_spec.rb:\\d+:in `/Three cute (.*)/'

}
        end

        it 'does not show --guess hint' do
          dsl.Given(/Three (.*) mice/) { |disability| }
          dsl.Given(/Three cute (.*)/) { |animal| }

          expect { search.call('Three cute mice').first }.to raise_error(Ambiguous, /#{elongated_error_message}/)
        end

        it 'does not raise Ambiguous error when multiple step definitions match' do
          dsl.Given(/Three (.*) mice/) { |disability| }
          dsl.Given(/Three (.*)/) { |animal| }

          expect { search.call('Three blind mice').first }.not_to raise_error
        end

        it 'picks right step definition when an equal number of capture groups' do
          right  = dsl.Given(/Three (.*) mice/) { |disability| }
          _wrong = dsl.Given(/Three (.*)/) { |animal| }

          expect(search.call('Three blind mice').first.step_definition).to eq right
        end

        it 'picks right step definition when an unequal number of capture groups' do
          right  = dsl.Given(/Three (.*) mice ran (.*)/) { |disability| }
          _wrong = dsl.Given(/Three (.*)/) { |animal| }

          expect(search.call('Three blind mice ran far').first.step_definition).to eq right
        end

        it 'picks most specific step definition when an unequal number of capture groups' do
          _general      = dsl.Given(/Three (.*) mice ran (.*)/) { |disability| }
          _specific     = dsl.Given(/Three blind mice ran far/) {}
          more_specific = dsl.Given(/^Three blind mice ran far$/) {}

          expect(search.call('Three blind mice ran far').first.step_definition).to eq more_specific
        end
      end

      # TODO: remove this - it's ... redundant
      # http://railsforum.com/viewtopic.php?pid=93881
      it "does not raise Redundant unless it's really redundant" do
        dsl.Given(/^(.*) (.*) user named '(.*)'$/) { |a, b, c| }
        dsl.Given(/^there is no (.*) user named '(.*)'$/) { |a, b| }
      end
    end
  end
end
