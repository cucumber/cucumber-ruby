module Cucumber
  module RbSupport
    class RbGroup
      attr_reader :val, :start

      def self.groups_from(regexp, step_name)
        match = regexp.match(step_name)
        if match
          n = 0
          match.captures.map do |val|
            n += 1
            new(val, match.offset(n)[0])
          end
        else
          nil
        end
      end

      def initialize(val, start)
        @val, @start = val, start
      end
    end
  end
end