require File.dirname(__FILE__) + '/../../spec_helper'
$:.unshift(File.dirname(__FILE__) + '/stubs')

describe "Rails world" do

  it "should run without Test::Unit.run defined" do
    require "mini_rails"

    step_mother = Cucumber::StepMother.new
    step_mother.load_natural_language('en')
    rb = step_mother.load_programming_language('rb')

    require "cucumber/rails/world"
  end

end