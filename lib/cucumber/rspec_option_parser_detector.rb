require 'optparse'

module Spec
  module Runner
    # Detects if RSpec's option parser is loaded and raises an error
    # if it is. (RSpec's option parser tries to parse ARGV, which
    # will fail when running cucumber)
    class OptionParser < ::OptionParser
      def self.bail
        raise <<-EOM

RSpec's 'spec/runner/option_parser' should *not* be loaded when you're running
Cucumber, but it seems it was loaded anyway. This is *not* a Cucumber bug.
Some other code is loading more RSpec code than it should. There can be several 
reasons for this. The most common ones are:

1) Some of your own code does require 'spec'. 
   Use require 'spec/expectations' instead.
2) Some of your own code does require 'spec/rails'.
   Use require 'spec/rails/expectations' instead.
3) Your Rails app's gem configuration is bad. Use
   config.gem 'rspec', :lib => false  
   config.gem 'rspec-rails', :lib => false  
4) Some other library you're using (indirectly)
   does require 'spec/runner/option_parser'.
   Analyze the stack trace below and get rid of it.

          EOM
      end

      if method_defined?(:options)
        bail
      end
      
      def self.method_added(*args)
        bail
      end
    end
  end
end
