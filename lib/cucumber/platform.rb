# frozen_string_literal: true

# Detect the platform we're running on so we can tweak behaviour in various places.
require 'rbconfig'
require 'cucumber/core/platform'

module Cucumber
  VERSION       = File.read(File.expand_path('../../VERSION', __dir__)).strip
  BINARY        = File.expand_path("#{File.dirname(__FILE__)}/../../bin/cucumber")
  LIBDIR        = File.expand_path("#{File.dirname(__FILE__)}/../../lib")
  RUBY_BINARY   = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])

  class << self
    attr_accessor :use_full_backtrace

    # @private
    def file_mode(mode, encoding = 'UTF-8')
      "#{mode}:#{encoding}"
    end
  end
  self.use_full_backtrace = false
end
