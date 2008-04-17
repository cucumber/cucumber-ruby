require 'optparse'

module Cucumber
  class CLI
    def self.execute
      parse(ARGV).execute!
    end
    
    def self.parse(args)
      cli = new(args)
      cli.parse_options!
      cli
    end

    def initialize(args)
      @args = args.dup
    end
    
    def parse_options!
    end
    
    def execute!
      puts "Running stories"
    end
  end
end