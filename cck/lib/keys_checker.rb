module CCK
  class KeysChecker
    def self.compare(found, expected)
      KeysChecker.new.compare(found, expected)
    end

    def compare(found, expected)
      errors = []

      found_keys = found.to_hash.keys
      expected_keys = expected.to_hash.keys

      return errors if found_keys.sort == expected_keys.sort

      default = default_values(found)

      missing_keys = (expected_keys - found_keys).reject do |field_name|
        default[field_name] == found[field_name] && default[field_name] == expected[field_name]
      end

      extra_keys = (found_keys - expected_keys).reject do |field_name|
        default[field_name] == found[field_name] && default[field_name] == expected[field_name]
      end

      errors << "Found extra keys in message #{found.class.name}: #{extra_keys}" unless extra_keys.empty?
      errors << "Missing keys in message #{found.class.name}: #{missing_keys}" unless missing_keys.empty?
      errors
    end

    def default_values(message)
      default = {}
      message.each_field { |field| default[field.name] = field.default_value }
      default
    end
  end
end
