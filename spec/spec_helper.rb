ENV['CUCUMBER_COLORS']=nil
$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__))

# For Travis....
if defined? Encoding
  Encoding.default_external = 'utf-8'
  Encoding.default_internal = 'utf-8'
end

require 'rubygems'
require 'bundler'
Bundler.setup

require 'cucumber'
$KCODE='u' if Cucumber::RUBY_1_8_7

RSpec.configure do |c|
  c.before do
    ::Cucumber::Term::ANSIColor.coloring = true
  end
end

module RSpec
  module WorkInProgress
    def pending_under platforms, reason, &block
      if [platforms].flatten.map(&:to_s).include? RUBY_PLATFORM
        pending "pending under #{platforms.inspect} because: #{reason}", &block
      else
        yield
      end
    end
  end
end


