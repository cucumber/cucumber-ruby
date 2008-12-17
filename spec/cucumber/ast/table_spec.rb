require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/ast/table'

module Cucumber
  module Ast
    describe Table do
      before do
        @table = Table.new([
          %w{1 22 333},
          %w{4444 55555 666666}
        ])
      end

      it "should have rows" do
        @table.rows[0].map{|cell| cell.value}.should == %w{1 22 333}
      end

      it "should have columns" do
        @table.columns[1].map{|cell| cell.value}.should == %w{22 55555}
      end

      it "should have same cell objects in rows and columns" do
        # 666666
        @table.rows[1][2].should equal(@table.columns[2][1])
      end

      it "should know about max width of a row" do
        @table.columns[1].width.should == 5
      end
      
      it "should space cells evenly with a simple block" do
        formatted = @table.map do |rows|
          "|" + rows.map do |cell|
            cell.to_s
          end.join("|") + "|"
        end.join("\n")
        ("\n"+formatted).should == %{
| 1    | 22    | 333    |
| 4444 | 55555 | 666666 |}
      end
    end
  end
end
