require 'spec_helper'
require 'cucumber/core_ext/array'

describe Array do

  describe "#rotate" do
    before do
      @array = [1, 2, 3]
    end
    
    it "returns a new array by rotating, whose first element is the element at the specified index" do
      @array.rotate(1).should == [2, 3, 1]
    end

    it "rotates by 1 if no index is specified" do
      @array.rotate.should == [2, 3, 1]
    end

    it "rotates in the counter direction for negative indexes" do
      @array.rotate(-1).should == [3, 1, 2]
    end

    it "loops around if the specified index exceeds the length of the array" do
      @array.rotate(4).should == [2, 3, 1]
    end

    it "loops around if the specified index exceeds the negative length of the array" do
      @array.rotate(-5).should == [2, 3, 1]
    end

    it "returns the same array if the specified index is 0" do
      @array.rotate(0).should == [1, 2, 3]
    end

    it "does not throw up if the the specified index is the last index" do
      @array.rotate(2).should == [3, 1, 2]
    end

    it "does not throw up for a single-element array" do
      single = [ :a ]
      single.rotate(0).should == single
    end
  end

end
