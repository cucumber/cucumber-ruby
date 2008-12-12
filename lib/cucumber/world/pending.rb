module Cucumber
  module World
    module Pending

      ##
      # Mark this step as pending
      def pending(message = "TODO")
        if block_given?
          begin
            yield
          rescue Exception => e
            raise Cucumber::ForcedPending.new(message)
          end
          raise Cucumber::ForcedPending.new("Expected pending '#{message}' to fail. No Error was raised.")
        else
          raise Cucumber::ForcedPending.new(message)
        end
      end

    end
  end
end
