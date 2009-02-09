require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Ast
    describe Tags do
      before do
        @tags = Tags.new(-1, %w{one two three})
      end

      it "should be among other tags" do
        @tags.should be_among(%w{one})
      end

      it "should be among other tags even with @ prefix" do
        @tags.should be_among(%w{@one})
      end

      it "should not be among other tags" do
        @tags.should_not be_among(%w{one ~two})
      end

      it "should not be among other tags with @ prefix" do
        @tags.should_not be_among(%w{one ~@two})
      end

      it "should be among other tags with irrelevant negative tag" do
        @tags.should be_among(%w{~bacon})
      end

      it "should not be among other tags with irrelevent tag" do
        @tags.should_not be_among(%w{bacon})
      end
    end
  end
end
