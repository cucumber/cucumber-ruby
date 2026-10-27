# frozen_string_literal: true

require 'rbconfig'
require 'cucumber/version'

module Cucumber
  BINARY        = File.expand_path("#{File.dirname(__FILE__)}/../../bin/cucumber")
  RUBY_BINARY   = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
  JRUBY         = defined?(JRUBY_VERSION)
  WINDOWS       = RbConfig::CONFIG['host_os'] =~ /mswin|mingw/

  class << self
    attr_writer :use_full_backtrace

    def use_full_backtrace
      @use_full_backtrace ||= false
    end

    def file_mode(mode, encoding = 'UTF-8')
      "#{mode}:#{encoding}"
    end
  end
end
