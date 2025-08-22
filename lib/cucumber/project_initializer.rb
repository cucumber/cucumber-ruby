# frozen_string_literal: true

module Cucumber
  # Generates generic file structure for a cucumber project
  class ProjectInitializer
    def run
      create_directory('features')
      create_directory('features/step_definitions')
      create_directory('features/support')
      create_file('features/support/env.rb')
    end

    private

    def create_directory(directory_name)
      create_directory_or_file(directory_name, command: :mkdir_p)
    end

    def create_file(filename)
      create_directory_or_file(filename, command: :touch)
    end

    def create_directory_or_file(name, command:)
      if File.exist?(name)
        puts "#{name} already exists"
      else
        puts "creating #{name}"
        FileUtils.send(command, name)
      end
    end
  end
end
