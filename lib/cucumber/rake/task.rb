module Cucumber
  module Rake
    # Defines a task for running features.
    # TODO: Base on http://github.com/dchelimsky/rspec/tree/master/lib/spec/rake/spectask.rb
    class Task
      LIB    = File.expand_path(File.dirname(__FILE__) + '/../..')
      BINARY = File.expand_path(File.dirname(__FILE__) + '/../../../bin/cucumber')

      attr_accessor :libs
      attr_accessor :step_list
      attr_accessor :step_pattern
      attr_accessor :feature_list
      attr_accessor :feature_pattern
      attr_accessor :cucumber_opts
      
      # Define a task
      def initialize(task_name = "features", desc = "Run Stories")
        @task_name, @desc = task_name, desc
        @libs = [LIB]

        yield self if block_given?

        @feature_pattern = "features/**/*.feature" if feature_pattern.nil? && feature_list.nil?
        @step_pattern =  "features/**/*.rb"    if step_pattern.nil? && step_list.nil?
        define_tasks
      end
    
      def define_tasks
        desc @desc
        task @task_name do
          args = []
          args << '-I'
          args << '"%s"' % libs.join(File::PATH_SEPARATOR)
          args << '"%s"' % BINARY
          args << (ENV['CUCUMBER_OPTS'] || cucumber_opts)

          step_files.each do |step_file|
            args << '--require'
            args << step_file
          end
          args << feature_files
          args.flatten!
          args.compact!
          ruby(args.join(" ")) # ruby(*args) is broken on Windows
        end
      end


      def feature_files # :nodoc:
        if ENV['STORY']
          FileList[ ENV['STORY'] ]
        else
          result = []
          result += feature_list.to_a if feature_list
          result += FileList[feature_pattern].to_a if feature_pattern
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