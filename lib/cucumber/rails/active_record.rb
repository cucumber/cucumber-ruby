if defined?(ActiveRecord::Base)
  Before('~@no-txn') do
    @__cucumber_use_txn = Cucumber::Rails::World.use_transactional_fixtures
    Cucumber::Rails::World.use_transactional_fixtures = true
  end

  Before('@no-txn') do
    @__cucumber_use_txn = Cucumber::Rails::World.use_transactional_fixtures
    Cucumber::Rails::World.use_transactional_fixtures = false
  end

  Before do
    if Cucumber::Rails::World.use_transactional_fixtures
      @__cucumber_ar_connection = ActiveRecord::Base.connection
      if @__cucumber_ar_connection.respond_to?(:increment_open_transactions)
        @__cucumber_ar_connection.increment_open_transactions
      else
        ActiveRecord::Base.__send__(:increment_open_transactions)
      end
      @__cucumber_ar_connection.begin_db_transaction
    end
    ActionMailer::Base.deliveries = [] if defined?(ActionMailer::Base)
  end

  After do
    if Cucumber::Rails::World.use_transactional_fixtures
      @__cucumber_ar_connection.rollback_db_transaction
      if @__cucumber_ar_connection.respond_to?(:decrement_open_transactions)
        @__cucumber_ar_connection.decrement_open_transactions
      else
        ActiveRecord::Base.__send__(:decrement_open_transactions)
      end
    end
    Cucumber::Rails::World.use_transactional_fixtures = @__cucumber_use_txn
  end
else
  module Cucumber::Rails
    def World.fixture_table_names; []; end # Workaround for projects that don't use ActiveRecord
  end
end
