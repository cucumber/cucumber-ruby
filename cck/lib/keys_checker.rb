module CCK
  class KeysChecker
    def self.compare(found, expected)
      errors = []

      found_keys = found.to_hash.keys
      expected_keys = expected.to_hash.keys

      return errors if found_keys.sort == expected_keys.sort

      missing_keys = expected_keys - found_keys
      extra_keys = found_keys - expected_keys

      errors << "Found extra keys in message #{found.class.name}: #{extra_keys}" unless extra_keys.empty?
      errors << "Missing keys in message #{found.class.name}: #{missing_keys}" unless missing_keys.empty?
      errors
    end
  end
end
