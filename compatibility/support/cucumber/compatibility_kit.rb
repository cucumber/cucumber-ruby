# frozen_string_literal: true

require_relative 'compatibility_kit/helpers'

require_relative 'compatibility_kit/keys_checker'
require_relative 'compatibility_kit/messages_comparator'

module Cucumber
  class CompatibilityKit
    class << self
      def supporting_code_for(example_name)
        path = File.join(local_features_folder_location, example_name)

        return path if File.directory?(path)

        raise ArgumentError, "No supporting code directory found locally for CCK example: #{example_name}"
      end

      private

      def local_features_folder_location
        File.expand_path("#{File.dirname(__FILE__)}/../../features/")
      end
    end
  end
end
