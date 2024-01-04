# frozen_string_literal: true

module CCK
  module Examples
    class << self
      def all
        gherkin + markdown
      end

      def gherkin
        Dir.entries(features_folder_location).select do |file_or_folder|
          next if file_or_folder.start_with?('.')

          gherkin_example?(File.join(features_folder_location, file_or_folder))
        end
      end

      def markdown
        Dir.entries(features_folder_location).select do |file_or_folder|
          next if file_or_folder.start_with?('.')

          markdown_example?(File.join(features_folder_location, file_or_folder))
        end
      end

      def supporting_code_for(example_name)
        path = File.join(features_folder_location, example_name)

        return path if File.directory?(path)

        raise ArgumentError, "No supporting code directory found locally for CCK example: #{example_name}"
      end

      private

      def features_folder_location
        File.expand_path("#{File.dirname(__FILE__)}/../../features/")
      end

      def gherkin_example?(example_folder)
        file_type_in_folder?('.feature', example_folder)
      end

      def markdown_example?(example_folder)
        file_type_in_folder?('.md', example_folder)
      end

      def file_type_in_folder?(extension, folder)
        Dir.entries(folder).any? { |file| File.extname(file) == extension }
      end
    end
  end
end
