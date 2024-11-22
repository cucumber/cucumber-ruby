# frozen_string_literal: true

require 'yaml'
require 'cucumber/encoding'
require 'cucumber/platform'
require 'cucumber/runtime'
require 'cucumber/cli/main'
require 'cucumber/step_definitions'
require 'cucumber/term/ansicolor'

module Cucumber
  class << self
    attr_accessor :wants_to_quit
    attr_reader :use_legacy_autoloader

    def logger
      return @log if @log

      @log = Logger.new($stdout)
      @log.level = Logger::INFO
      @log
    end

    def logger=(logger)
      @log = logger
    end

    def use_legacy_autoloader=(value)
      Cucumber.deprecate(
        'This will be phased out of cucumber and should not be used. It is only there to support legacy systems',
        '.use_legacy_autoloader',
        '11.0.0'
      )
      @use_legacy_autoloader = value
    end
  end
end
