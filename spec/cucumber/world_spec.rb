require File.dirname(__FILE__) + '/../spec_helper'
$:.unshift(File.dirname(__FILE__) + '/resources')

describe "Rails world" do

  it "should run without Test::Unit.run defined" do
    require "mocks"
    require "cucumber/rails/world"
  end

end