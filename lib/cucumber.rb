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
    attr_accessor :treats_ambiguous_as_fullwidth

    def logger
      return @log if @log
      @log = Logger.new(STDOUT)
      @log.level = Logger::INFO
      @log
    end

    def logger=(logger)
      @log = logger
    end

    def deprecate(class_name, method, message)
      return self # deprecation warnings will come in v2.1
      called_by = caller[1]
      warn("Deprecated: #{class_name}##{method} #{message}. Caller: #{called_by}")
    end

    if Cucumber::RUBY_1_9
      # Backported from Ruby 2.0 to 1.9
      def Hash(other)
        return {} if other.nil? || other == []
        raise TypeError, "can't convert #{other.class} into Hash" unless other.respond_to?(:to_hash)
        other.to_hash
      end
    else
      def Hash(other)
        Kernel::Hash(other)
      end
    end
  end
end
