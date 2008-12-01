require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Model
    describe Table do
      it "should convert into hash-array" do
        raw = [
          %w{name gender},
          %w{aslak male},
          %w{patty female},
        ]
        ha = Table.new(raw).hashes
        ha.should == [
          {'name' => 'aslak', 'gender' => 'male'},
          {'name' => 'patty', 'gender' => 'female'}
        ]
      end
    end
  end
end