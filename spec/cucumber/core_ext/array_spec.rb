require 'spec_helper'
require 'cucumber/core_ext/array'

describe Array do
  it "should provide an Array#rotate method" do
    array = [ :a, :b, :c ]

    array.rotate(0).should == [ :a, :b, :c ]
    array.rotate(1).should == [ :b, :c, :a ]
    array.rotate(2).should == [ :c, :a, :b ]
  end
end
