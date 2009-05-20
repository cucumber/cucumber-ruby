# Based on code from Brian Takita, Yurii Rashkovskii and Ben Mabey
# Adapted by Aslak Hellesøy

if defined?(ActiveRecord::Base)
  require 'test_help' 
else
  require 'action_controller/test_process'
  require 'action_controller/integration'
end

begin
  require 'test/unit/testresult'
rescue LoadError => e
  e.message << "\nYou must gem install test-unit. For more info see https://rspec.lighthouseapp.com/projects/16211/tickets/292"
  e.message << "\nAlso make sure you have rack 1.0.0 or higher."
  raise e
end

# So that Test::Unit doesn't launch at the end - makes it think it has already been run.
Test::Unit.run = true if Test::Unit.respond_to?(:run=)

$__cucumber_toplevel = self

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

      unless ::Rails.configuration.cache_classes
        warn "WARNING: You have set Rails' config.cache_classes to false (most likely in config/environments/test.rb).  This setting is known to break Cucumber's use_transactional_fixtures method. Set config.cache_classes to true if you want to use transactional fixtures.  For more information see https://rspec.lighthouseapp.com/projects/16211/tickets/165."
      end

      World.use_transactional_fixtures = true
      if defined?(ActiveRecord::Base)
        $__cucumber_toplevel.Before do
          @__cucumber_ar_connection = ActiveRecord::Base.connection
          if @__cucumber_ar_connection.respond_to?(:increment_open_transactions)
            @__cucumber_ar_connection.increment_open_transactions
          else
            ActiveRecord::Base.__send__(:increment_open_transactions)
          end
          @__cucumber_ar_connection.begin_db_transaction
          ActionMailer::Base.deliveries = [] if defined?(ActionMailer::Base)
        end
        
        $__cucumber_toplevel.After do
          @__cucumber_ar_connection.rollback_db_transaction
          if @__cucumber_ar_connection.respond_to?(:decrement_open_transactions)
            @__cucumber_ar_connection.decrement_open_transactions
          else
            ActiveRecord::Base.__send__(:decrement_open_transactions)
          end
        end
      end
    end

    def self.bypass_rescue
      ActionController::Base.class_eval do
        alias_method :rescue_action_without_bypass, :rescue_action

        def rescue_action(exception)
          raise exception
        end
      end

      begin
        ActionController::Failsafe.class_eval do
          alias_method :failsafe_response_without_bypass, :failsafe_response
        
          def failsafe_response(exception)
            raise exception
          end
        end
      rescue NameError # Failsafe was introduced in Rails 2.3.2
        ActionController::Dispatcher.class_eval do
          def self.failsafe_response(output, status, exception = nil)
            raise exception
          end
        end
      end
    end
  end
end

World do
  Cucumber::Rails::World.new
end
