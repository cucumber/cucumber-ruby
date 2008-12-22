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

      it "should iterate over each row" do
        rows = []
        Table.new(@raw).raw[1..-1].each do |name, gender|
          rows << [name, gender]
        end
        rows.should == [
          %w{aslak male},
          %w{patty female}
        ]
      end
    end
  end
end
