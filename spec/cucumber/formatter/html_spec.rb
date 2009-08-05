require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/formatter/html'

module Cucumber
  module Formatter
    describe Html do
      before(:each) do
        @out = StringIO.new
        @html = Html.new(mock("step mother"), @out, {})
      end

      it "should not raise an error when visiting a blank feature name" do
        lambda { @html.visit_feature_name("") }.should_not raise_error
      end
    end
  end
end

