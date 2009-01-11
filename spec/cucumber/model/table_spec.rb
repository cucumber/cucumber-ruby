require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Model
    describe Table do
      before do
        @raw = [
          %w{name gender},
          %w{aslak male},
          %w{patty female},
          ]
      end

      it "should convert into hash-array" do
        ha = Table.new(@raw).hashes
        ha.should == [
          {'name' => 'aslak', 'gender' => 'male'},
          {'name' => 'patty', 'gender' => 'female'}
        ]
      end
      
      it "should return the rows of the table" do
        ar = Table.new(@raw).rows
        ar.should == [
          ["aslak", "male"],
          ["patty", "female"]
        ]
      end
      
    end
  end
end
