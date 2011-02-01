require 'aruba/api'

# Monkey patch aruba to filter out some stuff
module Aruba::Api
  alias _all_stdout all_stdout
  
  def all_stdout
    out = _all_stdout

    # Remove absolute paths
    out.gsub!(/#{Dir.pwd}\/tmp\/aruba/, '.') 
    # Make duration predictable
    out.gsub!(/^\d+m\d+\.\d+s$/, '0m0.012s')
    # Remove SimpleCov message
    out.gsub!(/Coverage report generated for Cucumber Features to #{Dir.pwd}\/coverage\n$/, '')
    
    out
  end
end

require 'aruba/cucumber'

Before do |scenario|
  @scenario = scenario

  # Make sure bin/cucumber runs with SimpleCov enabled
  set_env('SIMPLECOV', 'true')
  
  # Set a longer timeout for aruba
  @aruba_timeout_seconds = 5
end
