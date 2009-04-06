require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/ast/table'

module Cucumber
  module Ast
    describe Table do
      before do
        @table = Table.new([
          %w{one four seven},
          %w{4444 55555 666666}
        ])
        def @table.cells_rows; super; end
        def @table.columns; super; end
      end

      it "should have rows" do
        @table.cells_rows[0].map{|cell| cell.value}.should == %w{one four seven}
      end

      it "should have columns" do
        @table.columns[1].map{|cell| cell.value}.should == %w{four 55555}
      end

      it "should have same cell objects in rows and columns" do
        # 666666
        @table.cells_rows[1].__send__(:[], 2).should equal(@table.columns[2].__send__(:[], 1))
      end

      it "should know about max width of a row" do
        @table.columns[1].__send__(:width).should == 5
      end

      it "should be convertible to an array of hashes" do
        @table.hashes.should == [
          {'one' => '4444', 'four' => '55555', 'seven' => '666666'}
        ]
      end

      it "should accept symbols as keys for the hashes" do
        @table.hashes.first[:one].should == '4444'
      end

      it "should allow map'ing columns" do
        @table.map_column!('one') { |v| v.to_i }
        @table.hashes.first['one'].should == 4444
      end

      it "should pass silently if a mapped column does not exist in non-strict mode" do
        lambda {
          @table.map_column!('two', false) { |v| v.to_i }
        }.should_not raise_error
      end

      it "should fail if a mapped column does not exist in strict mode" do
        lambda {
          @table.map_column!('two', true) { |v| v.to_i }
        }.should raise_error('The column named "two" does not exist')
      end

      describe ".transpose" do
        before(:each) do
          @table = Table.new([
            %w{one 1111},
            %w{two 22222}
          ])
        end
                
        it "should be convertible in to an array where each row is a hash" do 
          @table.transpose.hashes[0].should == {'one' => '1111', 'two' => '22222'}
        end
      end
      
      describe ".rows_hash" do
                
        it "should return a hash of the rows" do
          table = Table.new([
            %w{one 1111},
            %w{two 22222}
          ])
          table.rows_hash.should == {'one' => '1111', 'two' => '22222'}
        end
        
        it "should fail if the table doesn't have two columns" do
          faulty_table = Table.new([
            %w{one 1111 abc},
            %w{two 22222 def}
          ])
          lambda {
            faulty_table.rows_hash
          }.should raise_error('The table must have exactly 2 columns')
        end
      end
        
      it "should allow renaming columns" do
        table2 = @table.map_headers('one' => :three)
        table2.hashes.first[:three].should == '4444'
      end

      it "should copy column mappings when mapping headers" do
        @table.map_column!('one') { |v| v.to_i }
        table2 = @table.map_headers('one' => 'three')
        table2.hashes.first['three'].should == 4444
      end

      describe "replacing arguments" do

        before(:each) do
          @table = table = Table.new([
            %w{qty book},
            %w{<qty> <book>}
            ])
        end

        it "should return a new table with arguments replaced with values" do
          table_with_replaced_args = @table.arguments_replaced({'<book>' => 'Unbearable lightness of being', '<qty>' => '5'})

          table_with_replaced_args.hashes[0]['book'].should == 'Unbearable lightness of being'
          table_with_replaced_args.hashes[0]['qty'].should == '5'
        end

        it "should replace nil values with nil" do
          table_with_replaced_args = @table.arguments_replaced({'<book>' => nil})

          table_with_replaced_args.hashes[0]['book'].should == nil
        end

        it "should preserve values which don't match a placeholder when replacing with nil" do
          table = Table.new([
                              %w{book},
                              %w{cat}
                            ])
          table_with_replaced_args = table.arguments_replaced({'<book>' => nil})
          
          table_with_replaced_args.hashes[0]['book'].should == 'cat'
        end

        it "should not change the original table" do
          @table.arguments_replaced({'<book>' => 'Unbearable lightness of being'})

          @table.hashes[0]['book'].should_not == 'Unbearable lightness of being'
        end

        it "should not raise an error when there are nil values in the table" do
          table = Table.new([
                              ['book', 'qty'],
                              ['<book>', nil],
                            ])
          lambda{ 
            table.arguments_replaced({'<book>' => nil, '<qty>' => '5'})
          }.should_not raise_error
        end

      end
      
      it "should convert to sexp" do
        @table.to_sexp.should == 
          [:table, 
            [:row, 
              [:cell, "one"], 
              [:cell, "four"],
              [:cell, "seven"]
            ],
            [:row, 
              [:cell, "4444"], 
              [:cell, "55555"],
              [:cell, "666666"]]]
      end
    end
  end
end
