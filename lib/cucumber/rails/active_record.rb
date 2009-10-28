if defined?(ActiveRecord::Base)
  Before do
    $__cucumber_global_use_txn = !!Cucumber::Rails::World.use_transactional_fixtures if $__cucumber_global_use_txn.nil?
  end

  Before('~@no-txn') do
    Cucumber::Rails::World.use_transactional_fixtures = $__cucumber_global_use_txn
  end

  Before('@no-txn') do
    Cucumber::Rails::World.use_transactional_fixtures = false
  end

  Before do
    if Cucumber::Rails::World.use_transactional_fixtures
      @__cucumber_ar_connections = if ActiveRecord::Base.respond_to?(:connection_handler)
        ActiveRecord::Base.connection_handler.connection_pools.values.map {|pool| pool.connection}
      else
        [ActiveRecord::Base.connection] # Rails <= 2.1.2
      end
      @__cucumber_ar_connections.each do |__cucumber_ar_connection|
        if __cucumber_ar_connection.respond_to?(:increment_open_transactions)
          __cucumber_ar_connection.increment_open_transactions
        else
          ActiveRecord::Base.__send__(:increment_open_transactions)
        end
        __cucumber_ar_connection.begin_db_transaction
      end
    end
    ActionMailer::Base.deliveries = [] if defined?(ActionMailer::Base)
  end

  After do
    if Cucumber::Rails::World.use_transactional_fixtures
      @__cucumber_ar_connections.each do |__cucumber_ar_connection|
        __cucumber_ar_connection.rollback_db_transaction
        if __cucumber_ar_connection.respond_to?(:decrement_open_transactions)
          __cucumber_ar_connection.decrement_open_transactions
        else
          ActiveRecord::Base.__send__(:decrement_open_transactions)
        end
      end
    end
  end
else
  module Cucumber::Rails
    def World.fixture_table_names; []; end # Workaround for projects that don't use ActiveRecord
  end
end
