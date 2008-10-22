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
        receiver.__send__(method_name, *args) if receiver.respond_to?(method_name)
      end
    end

  end
end
