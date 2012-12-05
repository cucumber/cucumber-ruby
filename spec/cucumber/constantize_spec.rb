require 'spec_helper'

module Html end

module Cucumber
  describe Constantize do
    include Constantize

    it "loads html formatter" do
      clazz = constantize('Cucumber::Formatter::Html')
      clazz.name.should == 'Cucumber::Formatter::Html'
    end

    it "fails to load a made up class" do
      expect { constantize('My::MadeUp::ClassName') }.to raise_error(LoadError)
    end
  end
end
