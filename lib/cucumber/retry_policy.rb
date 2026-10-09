# frozen_string_literal: true

module Cucumber
  # Decides whether a failed test case is run again, honouring both the `--retry` and the `--retry-total` options.
  #
  # The retry filter asks it and then records what it did, the test runner asks it when it reports the outcome of a
  # test case. Both have to get the same answer, so #will_be_retried? never changes the state of the policy.
  class RetryPolicy
    def initialize(max_retries, max_permanent_failures)
      @max_retries = max_retries
      @max_permanent_failures = max_permanent_failures
      @retries = Hash.new(0)
      @permanent_failures = 0
    end

    def will_be_retried?(test_case, result)
      return false unless result.failed?
      return false if @permanent_failures >= @max_permanent_failures

      @retries[test_case] < @max_retries
    end

    def record_retry(test_case) = @retries[test_case] += 1

    def record_permanent_failure = @permanent_failures += 1
  end
end
