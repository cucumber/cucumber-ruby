require 'rubygems'
gem 'rspec'
require 'spec'
require 'spec/autorun'

ENV['CUCUMBER_COLORS']=nil
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'cucumber'
$:.unshift(File.dirname(__FILE__))

Spec::Runner.configure do |config|
  config.before(:each) do
    ::Term::ANSIColor.coloring = true
  end
end

alias running lambda
