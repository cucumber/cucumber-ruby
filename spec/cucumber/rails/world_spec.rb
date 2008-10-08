require File.dirname(__FILE__) + '/../../spec_helper'
$:.unshift(File.dirname(__FILE__) + '/stubs')

describe "Rails world" do

  it "should run without Test::Unit.run defined" do
    require "mini_rails"
    require "cucumber/rails/world"
  end

end