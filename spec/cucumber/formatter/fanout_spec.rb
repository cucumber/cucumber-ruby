require 'cucumber/formatter/fanout'

module Cucumber::Formatter
  describe Fanout do
    class DoesRespond
      def baz
        @called = true
      end

      def called?
        @called
      end
    end

    class DoesNotRespond
    end

    it "sends out messages to all recipients who can receive that message" do
      foo = DoesRespond.new
      bar = DoesNotRespond.new
      fanout = Fanout.new([foo, bar])
      fanout.baz
      expect(foo).to be_called
    end

    it "works with send" do
      foo = DoesRespond.new
      bar = DoesNotRespond.new
      fanout = Fanout.new([foo, bar])
      fanout.send :baz
      expect(foo).to be_called
    end
  end
end
