# Detect the platform we're running on so we can tweak behaviour
# in various places.
require 'rbconfig'

module Cucumber
unless defined?(Cucumber::VERSION)
  VERSION       = '1.3.8'
  BINARY        = File.expand_path(File.dirname(__FILE__) + '/../../bin/cucumber')
  LIBDIR        = File.expand_path(File.dirname(__FILE__) + '/../../lib')
  JRUBY         = defined?(JRUBY_VERSION)
  IRONRUBY      = defined?(RUBY_ENGINE) && RUBY_ENGINE == "ironruby"
  WINDOWS       = RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
  OS_X          = RbConfig::CONFIG['host_os'] =~ /darwin/
  WINDOWS_MRI   = WINDOWS && !JRUBY && !IRONRUBY
  RAILS         = defined?(Rails)
  RUBY_BINARY   = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
  RUBY_2_0      = RUBY_VERSION =~ /^2\.0/
  RUBY_1_9      = RUBY_VERSION =~ /^1\.9/
  RUBY_1_8_7    = RUBY_VERSION =~ /^1\.8\.7/

  class << self
    attr_accessor :use_full_backtrace

    def file_mode(m, encoding="UTF-8") #:nodoc:
      RUBY_1_8_7 ? m : "#{m}:#{encoding}"
    end
  end
  self.use_full_backtrace = false
end
end
