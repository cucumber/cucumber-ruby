require 'spec_helper'

module Cucumber
describe Runtime do
  subject { Runtime.new(options) }
  let(:options)     { {} }
  
  describe "#features_paths" do
    let(:options) { {:paths => ['foo/bar/baz.feature', 'foo/bar/features/baz.feature', 'other_features'] } }
    it "returns the value from configuration.paths" do
      subject.features_paths.should == options[:paths]
    end
  end
  
end
end