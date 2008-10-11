require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Tree
    describe Feature do
      it "should have padding_length 2 when alone" do
        feature = Feature.new('header')
        feature.padding_length.should == 2
      end
    end
  end
end
