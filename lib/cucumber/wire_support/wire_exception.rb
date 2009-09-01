module Cucumber::WireSupport
  # Proxy for an exception that occured at the remote end of the wire during invokation of 
  # a step defintion.
  class WireException < StandardError
    def initialize(json)
      @data = JSON.parse(json)
    end
    
    def message
      @data['message']
    end
    
    def backtrace
      @data['backtrace']
    end
  end
end