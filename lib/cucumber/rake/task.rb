module Cucumber
  module Rake
    # Defines a task for running stories.
    # TODO: Base on http://github.com/dchelimsky/rspec/tree/master/lib/spec/rake/spectask.rb
    class Task
      LIB    = File.expand_path(File.dirname(__FILE__) + '/../..')
      BINARY = File.expand_path(File.dirname(__FILE__) + '/../../../bin/cucumber')

      attr_accessor :libs
      attr_accessor :step_list
      attr_accessor :step_pattern
      attr_accessor :story_list
      attr_accessor :story_pattern
      attr_accessor :cucumber_opts
      
      # Define a task
      def initialize(stories_path = "stories")
        @stories_path = stories_path
        @libs = [LIB]

        yield self if block_given?

        @story_pattern = "#{@stories_path}/**/*.story" if story_pattern.nil? && story_list.nil?
        @step_pattern =  "#{@stories_path}/**/*.rb"    if step_pattern.nil? && step_list.nil?
        define_tasks
      end
    
      def define_tasks
        namespace :cucumber do
          desc "Run Cucumber Stories under #{@stories_path}"
          task @stories_path do
            args = []
            args << '-I'
            args << '"%s"' % libs.join(File::PATH_SEPARATOR)
            args << '"%s"' % BINARY
            args << (ENV['CUCUMBER_OPTS'] || cucumber_opts)

            step_files.each do |step_file|
              args << '--require'
              args << step_file
            end
            args << story_files
            args.flatten!
            args.compact!
            ruby(args.join(" ")) # ruby(*args) is broken on Windows
          end
        end
      end


      def story_files # :nodoc:
        if ENV['STORY']
          FileList[ ENV['STORY'] ]
        else
          result = []
          result += story_list.to_a if story_list
          result += FileList[story_pattern].to_a if story_pattern
          FileList[result]
        end
      end

      def step_files # :nodoc:
        if ENV['STEPS']
          FileList[ ENV['STEPS'] ]
        else
          result = []
          result += step_list.to_a if step_list
          result += FileList[step_pattern].to_a if step_pattern
          FileList[result]
        end
      end
    end
  end
end