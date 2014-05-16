require 'spec_helper'
require 'cucumber/rb_support/rb_transform'

module Cucumber
  module RbSupport
    describe RbTransform do
      def transform(regexp)
        RbTransform.new(nil, regexp, lambda { |a| })
      end

      describe "#to_s" do
        it "converts captures groups to non-capture groups" do
          expect(transform(/(a|b)bc/).to_s).to eq "(?:a|b)bc"
        end

        it "leaves non capture groups alone" do
          expect(transform(/(?:a|b)bc/).to_s).to eq "(?:a|b)bc"
        end

        it "strips away anchors" do
          expect(transform(/^xyz$/).to_s).to eq "xyz"
        end
      end
    end
  end
end
