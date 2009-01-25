module Cucumber
  class Broadcaster

    def initialize(receivers = [])
      @receivers = receivers
    end

    def method_missing(method_name, *args)
      @receivers.each  do |receiver|
        receiver.__send__(method_name, *args)
      end
    end

  end
end
