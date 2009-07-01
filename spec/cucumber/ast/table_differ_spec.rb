require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/ast/table_differ'

module Cucumber
  module Ast
    describe TableDiffer do
      before do
        @td = TableDiffer.new
      end
      
      it "should consider two equal tables equal" do
        t = t(%{
          | mineral | plant |
          | stone   | grass |
        })
        @td.diff(t, t).should == nil
      end

      it "should add missing columns to t1" do
        t1 = t(%{
          | mineral | plant |
          | stone   | grass |
        })
        t3 = t(%{
          | mineral | plant | animal |
          | stone   | grass | dog    |
        })
        t2 = t(%{
          | mineral | plant | animal | colour |
          | stone   | grass | dog    | yellow |
        })

        t1_n, _ = @td.normalize(t1.raw, t2.raw)
        t1_n.should == t(%{
          | mineral | plant |  |  |
          | stone   | grass |  |  |
        }).raw

        t1_n, _ = @td.normalize(t1.raw, t3.raw)
        t1_n.should == t(%{
          | mineral | plant |  |
          | stone   | grass |  |
        }).raw
      end

      it "should add missing columns to t2" do
        t1_a = t(%{
          | mineral | plant | animal |
          | stone   | grass | dog    |
        })
        t1_b = t(%{
          | mineral | plant | animal | colour |
          | stone   | grass | dog    | yellow |
        })
        t2 = t(%{
          | mineral | plant |
          | stone   | grass |
        })

        _, t2_n = @td.normalize(t1_a.raw, t2.raw)
        t2_n.should == t(%{
          | mineral | plant |  |
          | stone   | grass |  |
        }).raw

        _, t2_n = @td.normalize(t1_b.raw, t2.raw)
        t2_n.should == t(%{
          | mineral | plant |  |  |
          | stone   | grass |  |  |
        }).raw
      end
      
      it "should consider rows with anything equal" do
        r1 = [[1, 2, TableDiffer::Anything]]
        r2 = [[1, 2, 3]]
        
        r1.extend(Diff::LCS)
        diff = r1.diff(r2)
        diff.should == []
      end

      def t(text)
        Parser::TableParser.new.parse_or_fail(text.strip, nil, 0)
      end
    end
  end
end