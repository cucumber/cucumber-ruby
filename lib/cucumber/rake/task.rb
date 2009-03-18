require 'cucumber/platform'

module Cucumber
  module Rake
    # Defines a Rake task for running features.
    #
    # The simplest use of it goes something like:
    #
    #   Cucumber::Rake::Task.new
    #
    # This will create a task named 'features' described as 'Run Features with 
    # Cucumber'. It will use steps from 'features/**/*.rb' and features in 'features/**/*.feature'.
    #
    # To further configure the task, you can pass a block:
    #
    #   Cucumber::Rake::Task.new do |t|
    #     t.cucumber_opts = "--format progress"
    #   end
    #
    # This task can also be configured to be run with RCov:
    #
    #   Cucumber::Rake::Task.new do |t|
    #     t.rcov = true
    #   end
    # 
    # See the attributes for additional configuration possibilities.
    class Task
      LIB    = File.expand_path(File.dirname(__FILE__) + '/../..') # :nodoc:

      # Directories to add to the Ruby $LOAD_PATH
      attr_accessor :libs
      # Name of the cucumber binary to use for running features. Defaults to Cucumber::BINARY
      attr_accessor :binary
      # Array of paths to specific step definition files to use
      attr_accessor :step_list
      # File pattern for finding step definitions. Defaults to 
      # 'features/**/*.rb'.
      attr_accessor :step_pattern
      # Array of paths to specific features to run. 
      attr_accessor :feature_list
      # File pattern for finding features to run. Defaults to 
      # 'features/**/*.feature'. Can be overriden by the FEATURE environment variable.
      attr_accessor :feature_pattern
      # Extra options to pass to the cucumber binary. Can be overridden by the CUCUMBER_OPTS environment variable.
      attr_accessor :cucumber_opts
      # Run cucumber with RCov?
      attr_accessor :rcov
      # Extra options to pass to rcov
      attr_accessor :rcov_opts

      # Define a Rake
      def initialize(task_name = "features", desc = "Run Features with Cucumber")
        @task_name, @desc = task_name, desc
        @libs = ['lib']
        @rcov_opts = %w{--rails --exclude osx\/objc,gems\/}

        yield self if block_given?

        @feature_pattern = "features/**/*.feature" if feature_pattern.nil? && feature_list.nil?
        @step_pattern    = "features/**/*.rb"      if step_pattern.nil? && step_list.nil?

        @binary = binary.nil? ? Cucumber::BINARY : File.expand_path(binary)
        @libs.insert(0, LIB) if binary == Cucumber::BINARY

        define_task
      end

      def define_task # :nodoc:
        desc @desc
        task @task_name do
          ruby(arguments_for_ruby_execution.join(" ")) # ruby(*args) is broken on Windows
        end
      end

      def arguments_for_ruby_execution(task_args = nil) # :nodoc:
        lib_args     = ['"%s"' % libs.join(File::PATH_SEPARATOR)]
        cucumber_bin = ['"%s"' % binary]
        cuc_opts     = [(ENV['CUCUMBER_OPTS'] || cucumber_opts)]

        step_files(task_args).each do |step_file|
          cuc_opts << '--require'
          cuc_opts << step_file
        end

        if rcov
          args = (['-I'] + lib_args + ['-S', 'rcov'] + rcov_opts +
            cucumber_bin + ['--'] + cuc_opts + feature_files(task_args)).flatten
        else
          args = (['-I'] + lib_args + cucumber_bin + cuc_opts + feature_files(task_args)).flatten
        end

        args
      end

      def feature_files(task_args = nil) # :nodoc:
        if ENV['FEATURE']
          FileList[ ENV['FEATURE'] ]
        else
          result = []
          result += feature_list.to_a if feature_list
          result += FileList[feature_pattern].to_a if feature_pattern
          FileList[result]
        end
      end

      def step_files(task_args = nil) # :nodoc:
        if ENV['STEPS']
          FileList[ ENV['STEPS'] ]
        else
          result = []
          result += Array(step_list) if step_list
          result += Array(FileList[step_pattern]) if step_pattern
          FileList[result]
        end
      end
    end

    class FeatureTask < Task

      def initialize(task_name = "feature", desc = "Run a specified feature with Cucumber.  #{task_name}[feature_name]")
        super(task_name, desc)
      end

      def define_task # :nodoc:
        desc @desc
        task @task_name, :feature_name do |t, args|
          ruby(arguments_for_ruby_execution(args).join(" ")) # ruby(*args) is broken on Windows
        end
      end

      def feature_files(task_arguments) # :nodoc:
        FileList[File.join("features", "**", "#{task_arguments[:feature_name]}.feature")]
      end

    end

  end
end
