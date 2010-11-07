require 'aruba'

Before do |scenario|
  @scenario = scenario

  # Make sure bin/cucumber runs with SimpleCov enabled
  set_env('SIMPLECOV', 'true')
end

AfterStep do
  @last_stderr.gsub!(/#{Dir.pwd}\/tmp\/aruba/, '.') if @last_stderr
  if @last_stdout
    # Remove absolute paths
    @last_stdout.gsub!(/#{Dir.pwd}\/tmp\/aruba/, '.') 
    # Make duration predictable
    @last_stdout.gsub!(/^\d+m\d+\.\d+s$/, '0m0.012s') if @last_stdout
    # Remove SimpleCov message
    @last_stdout.gsub!(/^Coverage report generated for Cucumber Features to #{Dir.pwd}\/coverage$/, '')
  end
end