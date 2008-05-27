# Based on code from Brian Takita, Yurii Rashkovskii and Ben Mabey
# Adapted by Aslak Hellesøy

if defined?(ActiveRecord::Base)
  require 'test_help' 
else
  require 'action_controller/test_process'
  require 'action_controller/integration'
end
require 'test/unit/testresult'
require 'spec'
require 'spec/rails'

# These allow exceptions to come through as opposed to being caught and hvaing non-helpful responses returned.
ActionController::Base.class_eval do
  def perform_action
    perform_action_without_rescue
  end
end
Dispatcher.class_eval do
  def self.failsafe_response(output, status, exception = nil)
    raise exception
  end
end

# So that Test::Unit doesn't launch at the end - makes it think it has already been run.
Test::Unit.run = true

# Hack to stop RSpec from dumping the summary
Spec::Runner::Options.class_eval do
  def examples_should_be_run?
    false
  end
end

ActionController::Integration::Session.send(:include, Spec::Matchers)
ActionController::Integration::Session.send(:include, Spec::Rails::Matchers)

module Cucumber
  module Rails
    class World < ActionController::IntegrationTest
      if defined?(ActiveRecord::Base)
        self.use_transactional_fixtures = true
      else
        def self.fixture_table_names; []; end # Workaround for projects that don't use ActiveRecord
      end

      def initialize #:nodoc:
        @_result = Test::Unit::TestResult.new
      end
    end
  end
end

World do
  Cucumber::Rails::World.new
end

if defined?(ActiveRecord::Base)
  Before do
    ActiveRecord::Base.send :increment_open_transactions
    ActiveRecord::Base.connection.begin_db_transaction
  end
  
  After do
    ActiveRecord::Base.connection.rollback_db_transaction
    ActiveRecord::Base.send :decrement_open_transactions
  end
end
