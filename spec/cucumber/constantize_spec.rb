require 'spec_helper'

module Cucumber
  describe Constantize do
    include Constantize

    it "loads html formatter" do
      clazz = constantize('Cucumber::Formatter::Html')
      clazz.name.should == 'Cucumber::Formatter::Html'
    end
  end
end