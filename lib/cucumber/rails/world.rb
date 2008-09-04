# Based on code from Brian Takita, Yurii Rashkovskii and Ben Mabey
# Adapted by Aslak Hellesøy

if defined?(ActiveRecord::Base)
  require 'test_help' 
else
  require 'action_controller/test_process'
  require 'action_controller/integration'
end
require 'test/unit/testresult'

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

$main = self

module Cucumber #:nodoc:
  module Rails
    # All scenarios will execute in the context of a new instance of World.
    class World < ActionController::IntegrationTest
      if defined?(ActiveRecord::Base)
        self.use_transactional_fixtures = false
      else
        def self.fixture_table_names; []; end # Workaround for projects that don't use ActiveRecord
      end

      def initialize #:nodoc:
        @_result = Test::Unit::TestResult.new
      end
    end

    def self.use_transactional_fixtures
      Cucumber::Rails::World.use_transactional_fixtures = true
      if defined?(ActiveRecord::Base)
        $main.Before do
          if defined?(ActiveRecord::Base)
            if ActiveRecord::Base.connection.respond_to?(:increment_open_transactions)
              ActiveRecord::Base.connection.increment_open_transactions
            else
              ActiveRecord::Base.send :increment_open_transactions
            end
          end
          ActiveRecord::Base.connection.begin_db_transaction
          ActionMailer::Base.deliveries = [] if defined?(ActionMailer::Base)
        end
        
        $main.After do
          if defined?(ActiveRecord::Base)
            ActiveRecord::Base.connection.rollback_db_transaction
            if ActiveRecord::Base.connection.respond_to?(:decrement_open_transactions)
              ActiveRecord::Base.connection.decrement_open_transactions
            else
              ActiveRecord::Base.send :decrement_open_transactions
            end
          end
        end
      end
    end

  end
end

World do
  Cucumber::Rails::World.new
end

ActionMailer::Base.delivery_method = :test if defined?(ActionMailer::Base)
