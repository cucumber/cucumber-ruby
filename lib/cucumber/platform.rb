# frozen_string_literal: true

require 'rbconfig'
require 'cucumber/core/platform'

module Cucumber
  VERSION       = File.read(File.expand_path('../../VERSION', __dir__)).strip
  BINARY        = File.expand_path("#{File.dirname(__FILE__)}/../../bin/cucumber")
  LIBDIR        = File.expand_path("#{File.dirname(__FILE__)}/../../lib")
  RUBY_BINARY   = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])

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
