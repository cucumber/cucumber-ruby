require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Ast
    describe Tags do
      before do
        @tags = Tags.new(-1, %w{one two three})
      end

      it "should be among other tags" do
        @tags.should have_tags(%w{one})
      end

      it "should not be among other tags with irrelevent tag" do
        @tags.should_not have_tags(%w{bacon})
      end
    end
  end
end
