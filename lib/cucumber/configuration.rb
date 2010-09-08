module Cucumber
  class Configuration
    def self.default
      new
    end
    
    def initialize(options = {})
      @options = options
    end
    
    def dry_run?
      @options[:dry_run]
    end
    
    def guess?
      @options[:guess]
    end
    
    def options
      warn("#options is deprecated. Please use the configuration object instead. #{caller[1]}")
      @options
    end
  end
end