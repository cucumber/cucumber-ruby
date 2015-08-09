# Detect the platform we're running on so we can tweak behaviour
# in various places.
require 'rbconfig'

module Cucumber
  unless defined?(Cucumber::VERSION)
    VERSION       = '2.0.2'
    BINARY        = File.expand_path(File.dirname(__FILE__) + '/../../bin/cucumber')
    LIBDIR        = File.expand_path(File.dirname(__FILE__) + '/../../lib')
    JRUBY         = defined?(JRUBY_VERSION)
    WINDOWS       = RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
    OS_X          = RbConfig::CONFIG['host_os'] =~ /darwin/
    WINDOWS_MRI   = WINDOWS && !JRUBY
    RAILS         = defined?(Rails)
    RUBY_BINARY   = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
    RUBY_2_2      = RUBY_VERSION =~ /^2\.2/
    RUBY_2_1      = RUBY_VERSION =~ /^2\.1/
    RUBY_2_0      = RUBY_VERSION =~ /^2\.0/
    RUBY_1_9      = RUBY_VERSION =~ /^1\.9/

    class << self
      attr_accessor :use_full_backtrace

      # @private
      def file_mode(m, encoding="UTF-8")
        "#{m}:#{encoding}"
      end
    end
    self.use_full_backtrace = false
  end
end
