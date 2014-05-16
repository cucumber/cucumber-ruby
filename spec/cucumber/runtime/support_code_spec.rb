require 'spec_helper'

module Cucumber
  describe Runtime::SupportCode do
    let(:user_interface) { double('user interface') }
    subject { Runtime::SupportCode.new(user_interface, options) }
    let(:options) { {} }
    let(:dsl) do
      @rb = subject.load_programming_language('rb')
      Object.new.extend(RbSupport::RbDsl)
    end

    it "formats step names" do
      dsl.Given(/it (.*) in (.*)/) { |what, month| }
      dsl.Given(/nope something else/) { |what, month| }

      format = subject.step_match("it snows in april").format_args("[%s]")

      expect(format).to eq "it [snows] in [april]"
    end

    it "caches step match results" do
      dsl.Given(/it (.*) in (.*)/) { |what, month| }

      step_match = subject.step_match("it snows in april")

      expect(@rb).not_to receive(:step_matches)
      second_step_match = subject.step_match("it snows in april")

      expect(step_match).to equal(second_step_match)
    end

    describe "resolving step defintion matches" do

      it "raises Ambiguous error with guess hint when multiple step definitions match" do
        expected_error = %{Ambiguous match of "Three blind mice":

spec/cucumber/runtime/support_code_spec.rb:\\d+:in `/Three (.*) mice/'
spec/cucumber/runtime/support_code_spec.rb:\\d+:in `/Three blind (.*)/'

You can run again with --guess to make Cucumber be more smart about it
}
        dsl.Given(/Three (.*) mice/) {|disability|}
        dsl.Given(/Three blind (.*)/) {|animal|}

        expect(-> {
          subject.step_match("Three blind mice")
        }).to raise_error(Ambiguous, /#{expected_error}/)
      end

      describe "when --guess is used" do
        let(:options) { {:guess => true} }

        it "does not show --guess hint" do
        expected_error = %{Ambiguous match of "Three cute mice":

spec/cucumber/runtime/support_code_spec.rb:\\d+:in `/Three (.*) mice/'
spec/cucumber/runtime/support_code_spec.rb:\\d+:in `/Three cute (.*)/'

}
          dsl.Given(/Three (.*) mice/) {|disability|}
          dsl.Given(/Three cute (.*)/) {|animal|}

          expect(-> {
            subject.step_match("Three cute mice")
          }).to raise_error(Ambiguous, /#{expected_error}/)
        end

        it "does not raise Ambiguous error when multiple step definitions match" do
          dsl.Given(/Three (.*) mice/) {|disability|}
          dsl.Given(/Three (.*)/) {|animal|}

          expect(-> {
            subject.step_match("Three blind mice")
          }).not_to raise_error
        end

        it "does not raise NoMethodError when guessing from multiple step definitions with nil fields" do
          dsl.Given(/Three (.*) mice( cannot find food)?/) {|disability, is_disastrous|}
          dsl.Given(/Three (.*)?/) {|animal|}

          expect(-> {
            subject.step_match("Three blind mice")
          }).not_to raise_error
        end

        it "picks right step definition when an equal number of capture groups" do
          right = dsl.Given(/Three (.*) mice/) {|disability|}
          wrong = dsl.Given(/Three (.*)/) {|animal|}

          expect(subject.step_match("Three blind mice").step_definition).to eq right
        end

        it "picks right step definition when an unequal number of capture groups" do
          right = dsl.Given(/Three (.*) mice ran (.*)/) {|disability|}
          wrong = dsl.Given(/Three (.*)/) {|animal|}

          expect(subject.step_match("Three blind mice ran far").step_definition).to eq right
        end

        it "picks most specific step definition when an unequal number of capture groups" do
          general       = dsl.Given(/Three (.*) mice ran (.*)/) {|disability|}
          specific      = dsl.Given(/Three blind mice ran far/) do; end
          more_specific = dsl.Given(/^Three blind mice ran far$/) do; end

          expect(subject.step_match("Three blind mice ran far").step_definition).to eq more_specific
        end
      end

      it "raises Undefined error when no step definitions match" do
        expect(-> {
          subject.step_match("Three blind mice")
        }).to raise_error(Undefined)
      end

      # http://railsforum.com/viewtopic.php?pid=93881
      it "does not raise Redundant unless it's really redundant" do
        dsl.Given(/^(.*) (.*) user named '(.*)'$/) {|a,b,c|}
        dsl.Given(/^there is no (.*) user named '(.*)'$/) {|a,b|}
      end
    end
  end
end
