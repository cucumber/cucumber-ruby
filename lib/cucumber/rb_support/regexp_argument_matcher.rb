require 'cucumber/gherkin/formatter/argument'

module Cucumber
  module RbSupport
    class RegexpArgumentMatcher
      def self.arguments_from(regexp, step_name)
        match = regexp.match(step_name)
        if match
          n = 0
          match.captures.map do |val|
            n += 1
            offset = match.offset(n)[0]
            Cucumber::Gherkin::Formatter::Argument.new(offset, val)
          end
        else
          nil
        end
      end
    end
  end
end
