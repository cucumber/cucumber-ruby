require 'spec_helper'
require 'cucumber/core_ext/array'

describe Array do

  describe "#rotate" do
    before do
      @array = [ :a, :b, :c ]
    end
    
    it "exhibits identical behavior to Array#rotate from Ruby > 1.9" do
      @array.rotate(1).should == [ :b, :c, :a ]
    end

    it "returns the same array if the specified index is 0" do
      @array.rotate(0).should == [ :a, :b, :c ]
    end

    it "does not throw up if the the specified index is the last index" do
      @array.rotate(2).should == [ :c, :a, :b ]
    end

    it "does not throw up for a single-element array" do
      single = [ :a ]
      single.rotate(0).should == single
    end
  end

end
