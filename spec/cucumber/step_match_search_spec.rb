# frozen_string_literal: true

require 'cucumber/step_match_search'
require 'cucumber/glue/dsl'
require 'cucumber/glue/registry_and_more'
require 'cucumber/configuration'

module Cucumber
  describe StepMatchSearch do
    let(:search) { StepMatchSearch.new(registry.method(:step_matches), configuration) }
    let(:registry) { Glue::RegistryAndMore.new(runtime, configuration) }
    let(:runtime) do
      # TODO: break out step definitions collection from Glue::RegistryAndMore so we don't need this
      :unused
    end
    let(:configuration) { Configuration.new(options) }
    let(:options) { {} }
    let(:dsl) do
      # TODO: stop relying on implicit global state
      registry
      Object.new.extend(Glue::Dsl)
    end

    context 'caching' do
      it 'caches step match results' do
        dsl.Given(/it (.*) in (.*)/) { |what, month| }

        step_match = search.call('it snows in april').first

        expect(registry).not_to receive(:step_matches)
        second_step_match = search.call('it snows in april').first

        expect(step_match).to equal(second_step_match)
      end
    end

    describe 'resolving step defintion matches' do
      it 'raises Ambiguous error with guess hint when multiple step definitions match' do
        expected_error = %{Ambiguous match of "Three blind mice":

spec/cucumber/step_match_search_spec.rb:\\d+:in `/Three (.*) mice/'
spec/cucumber/step_match_search_spec.rb:\\d+:in `/Three blind (.*)/'

You can run again with --guess to make Cucumber be more smart about it
}
        dsl.Given(/Three (.*) mice/) { |disability| }
        dsl.Given(/Three blind (.*)/) { |animal| }

        expect(-> { search.call('Three blind mice').first }).to raise_error(Ambiguous, /#{expected_error}/)
      end

      describe 'when --guess is used' do
        let(:options) { { guess: true } }

        it 'does not show --guess hint' do
          expected_error = %{Ambiguous match of "Three cute mice":

spec/cucumber/step_match_search_spec.rb:\\d+:in `/Three (.*) mice/'
spec/cucumber/step_match_search_spec.rb:\\d+:in `/Three cute (.*)/'

}
          dsl.Given(/Three (.*) mice/) { |disability| }
          dsl.Given(/Three cute (.*)/) { |animal| }

          expect(-> { search.call('Three cute mice').first }).to raise_error(Ambiguous, /#{expected_error}/)
        end

        it 'does not raise Ambiguous error when multiple step definitions match' do
          dsl.Given(/Three (.*) mice/) { |disability| }
          dsl.Given(/Three (.*)/) { |animal| }

          expect(-> { search.call('Three blind mice').first }).not_to raise_error
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
          _specific     = dsl.Given(/Three blind mice ran far/) { ; }
          more_specific = dsl.Given(/^Three blind mice ran far$/) { ; }

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
