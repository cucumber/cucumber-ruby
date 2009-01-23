module Cucumber
  class Broadcaster

    def initialize(receivers = [])
      @receivers = receivers
    end

    def register(receiver)
      @receivers << receiver
    end

    def method_missing(method_name, *args)
      @receivers.each  do |receiver|
        r = (receiver == STDOUT) ? Kernel : receiver # Needed to make colors work on Windows
        r.__send__(method_name, *args)
      end
    end

  end
end
