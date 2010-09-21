module Cucumber
  # The base class for configuring settings for a Cucumber run.
  class Configuration
    def self.default
      new
    end
    
    def self.parse(argument)
      return new(argument) if argument.is_a?(Hash)
      argument
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
    
    def strict?
      @options[:strict]
    end
    
    def expand? 
      @options[:expand]
    end
    
    def paths
      @options[:paths]
    end
  end
end