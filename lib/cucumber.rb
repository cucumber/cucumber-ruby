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

    def deprecate(message, method, remove_after_version)
      Kernel.warn(
        "\nWARNING: #{method} is deprecated" \
          " and will be removed after version #{remove_after_version}. #{message}.\n" \
          "(Called from #{caller(3..3).first})"
      )
    end

    def logger
      return @log if @log

      @log = Logger.new($stdout).tap { |log| log.level = Logger::INFO }
    end

    def logger=(logger)
      @log = logger
    end
  end
end
