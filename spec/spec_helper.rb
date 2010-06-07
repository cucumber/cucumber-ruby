ENV['CUCUMBER_COLORS']=nil
$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__))

require 'rubygems'

begin
  require 'rspec'
  require 'rspec/autorun'
  RSpec.configure do |c|
    c.color_enabled = true
    c.before(:each) do
      ::Term::ANSIColor.coloring = true
    end
  end
rescue LoadError
  require 'spec'
  require 'spec/autorun'
  Spec::Runner.configure do |c|
    c.before(:each) do
      ::Term::ANSIColor.coloring = true
    end
  end
end

require 'cucumber'
$KCODE='u' unless Cucumber::RUBY_1_9

alias running lambda
