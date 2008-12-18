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
        @table.extend(Module.new{
          attr_reader :raw
        })
        def @table.rows; super; end
        def @table.columns; super; end
      end

      it "should have rows" do
        @table.rows[0].map{|cell| cell.value}.should == %w{1 22 333}
      end

      it "should have columns" do
        @table.columns[1].map{|cell| cell.value}.should == %w{22 55555}
      end

      it "should have same cell objects in rows and columns" do
        # 666666
        @table.rows[1].__send__(:[], 2).should equal(@table.columns[2].__send__(:[], 1))
      end

      it "should know about max width of a row" do
        @table.columns[1].__send__(:width).should == 5
      end
    end
  end
end
