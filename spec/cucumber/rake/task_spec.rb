require 'spec_helper'
require 'cucumber/rake/task'
require 'rake'

module Cucumber
  module Rake
    describe Task do

      describe "#cucumber_opts" do
        before { subject.cucumber_opts = opts }

        context "when set via array" do
          let(:opts) { [ :foo, :bar ] }
          it { expect(subject.cucumber_opts).to be opts }
        end

        context "when set via space-delimited string" do
          let(:opts) { "foo bar" }
          it { expect(subject.cucumber_opts).to eq [ "foo", "bar" ] }
        end
      end

    end
  end
end
