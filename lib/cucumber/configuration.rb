module Cucumber
  class Configuration
    def self.default
      new
    end
    
    def options
      warn("#options is deprecated. Please use the configuration object instead")
      {}
    end
  end
end