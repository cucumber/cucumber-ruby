module Cucumber
module Gherkin
  module Formatter
    class Hashable
      def to_hash
        ivars = instance_variables
        # When tests are runn with therubyracer (JavaScript), an extra field might
        # exist - added by Ref::WeakReference
        # https://github.com/bdurand/ref/blob/master/lib/ref/weak_reference/pure_ruby.rb
        # Remove it - we don't want it in the JSON.
        ivars.delete(:@__weak_backreferences__)
        ivars.inject({}) do |hash, ivar|
          value = instance_variable_get(ivar)
          value = value.to_hash if value.respond_to?(:to_hash)
          if Array === value
            value = value.map do |e|
              e.respond_to?(:to_hash) ? e.to_hash : e
            end
          end
          hash[ivar[1..-1]] = value unless [[], nil].index(value)
          hash
        end
      end
    end
  end
end
end
