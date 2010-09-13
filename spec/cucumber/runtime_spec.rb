require 'spec_helper'

module Cucumber
describe Runtime do
  let(:configuration) { Cucumber::Configuration.new(configuration_options) }
  subject             { Cucumber::Runtime.new(configuration) }

  describe "#features_paths" do
    let(:configuration_options) { {:paths => ['foo/bar/baz.feature', 'foo/bar/features/baz.feature', 'other_features'] } }
    it "returns the value from configuration.paths" do
      subject.features_paths.should == configuration.paths
    end
  end
end
end