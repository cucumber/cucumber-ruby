module Cucumber
  module Reports

    class FanOut
      include ::Cucumber.initializer(:reports)

      REPORT_API = [
        :before_test_case,
        :before_test_step,
        :after_test_case,
        :after_test_step,
        :done,
      ]

      USER_INTERFACE_API = REPORT_API + [
        :embed,
        :ask,
        :puts
      ]

      USER_INTERFACE_API.each do |message|
        define_method(message) do |*args|
          reports.each { |report| report.send(message, *args) if report.respond_to?(message) }
        end
      end

    end

  end
end
