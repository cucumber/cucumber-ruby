module Cucumber
  class Broadcaster
    @@instances = []

    def initialize(receivers = [])
      @receivers = receivers
      @@instances << self
    end

    def self.announce(announcement)
      instances.each do |instance|
        instance.announce(announcement)
      end
    end

    def self.instances
      @@instances
    end

    def method_missing(method_name, *args)
      @receivers.each  do |receiver|
        receiver.__send__(method_name, *args)
      end
    end
    
  end
end
