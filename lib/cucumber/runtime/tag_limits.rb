require "cucumber/runtime/tag_limits/test_case_index"
require "cucumber/runtime/tag_limits/filter"
require "cucumber/runtime/tag_limits/verifier"

module Cucumber
  class Runtime
    module TagLimits
      class TagLimitExceededError < StandardError
        def initialize(*limit_breaches)
          super(limit_breaches.map(&:to_s).join("\n"))
        end
      end
    end
  end
end
