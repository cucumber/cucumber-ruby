# frozen_string_literal: true

module CCK
  module CompatibilityKit
    class << self
      def all_examples
        gherkin_examples + markdown_examples
      end

      def gherkin_examples
        Dir.entries(examples_path).select do |file_or_folder|
          next if file_or_folder.start_with?('.')

          gherkin_example?(File.join(examples_path, file_or_folder))
        end
      end

      def markdown_examples
        Dir.entries(examples_path).select do |file_or_folder|
          next if file_or_folder.start_with?('.')

          markdown_example?(File.join(examples_path, file_or_folder))
        end
      end

      def examples_path
        File.expand_path("#{File.dirname(__FILE__)}/../../features/")
      end

      def example_path(example_name)
        path = File.join(examples_path, example_name)

        return path if File.directory?(path)

        raise ArgumentError, "No CCK example exists for #{example_name}"
      end

      private

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
