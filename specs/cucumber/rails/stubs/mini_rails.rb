# Define some stubs to fake Rails...
module ActiveRecord
  class Base
  end
end

module ActionController
  class Dispatcher
  end

  class Base
  end

  class IntegrationTest
    def self.use_transactional_fixtures=(x)
    end
  end
end
