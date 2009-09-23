require 'cucumber/step_argument'

module Cucumber
  module RbSupport
    class RegexpArgumentMatcher
      def arguments_from(regexp, step_name)
        match = regexp.match(step_name)
        if match
          n = 0
          match.captures.map do |val|
            n += 1
            StepArgument.new(val, match.offset(n)[0])
          end
        else
          nil
        end
      end
    end
  end
end