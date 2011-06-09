require 'aruba/api'

# Monkey patch aruba to filter out some stuff
module Aruba::Api
  alias all_stdout_with_color all_stdout
  
  def all_stdout
    unrandom(uncolor(all_stdout_with_color))
  end

  def uncolor(out)
    out.gsub(/\e\[\d+(?>(;\d+)*)m/, '') # Remove ANSI escapes
  end

  def unrandom(out)
    out
    .gsub(/#{Dir.pwd}\/tmp\/aruba/, '.') # Remove absolute paths
    .gsub(/^\d+m\d+\.\d+s$/, '0m0.012s') # Make duration predictable
    .gsub(/Coverage report generated for Cucumber Features to #{Dir.pwd}\/coverage.*\n$/, '')     # Remove SimpleCov message
  end
end

require 'aruba/cucumber'

Before do |scenario|
  @scenario = scenario

  # Make sure bin/cucumber runs with SimpleCov enabled
  # set_env('SIMPLECOV', 'true')
  
  # Set a longer timeout for aruba
  @aruba_timeout_seconds = 5
end
