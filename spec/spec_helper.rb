ENV['CUCUMBER_COLORS']=nil
$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler'
Bundler.setup

require 'cucumber'
$KCODE='u' unless Cucumber::RUBY_1_9

RSpec.configure do |c|
  c.before do
    ::Term::ANSIColor.coloring = true
  end
end
