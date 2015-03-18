ENV['CUCUMBER_COLORS'] = nil
$:.unshift(File.dirname(__FILE__))

# For Travis....
require 'cucumber/encoding'

load File.expand_path(File.dirname(__FILE__) + '/../spec/simplecov_setup.rb')

require 'pry'

require 'cucumber'

RSpec.configure do |c|
  c.before do
    ::Cucumber::Term::ANSIColor.coloring = true
  end
end

module RSpec
  module WorkInProgress
    def pending_under(platforms, reason, &block)
      if [platforms].flatten.map(&:to_s).include? RUBY_PLATFORM
        pending "pending under #{platforms.inspect} because: #{reason}", &block
      else
        yield
      end
    end
  end
end
