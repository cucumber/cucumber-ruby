module Cucumber
  module RbSupport
    # A Group encapsulates data from a regexp match.
    # A Group instance has to attributes:
    #
    # * The value of the group
    # * The start index from the matched string where the group value starts
    #
    # See rb_group_spec.rb for examples
    #
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