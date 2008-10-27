module Cucumber
  module Rake
    # Defines a task for running features.
    class Task
      LIB    = File.expand_path(File.dirname(__FILE__) + '/../..')

      attr_accessor :libs
      attr_accessor :binary
      attr_accessor :step_list
      attr_accessor :step_pattern
      attr_accessor :feature_list
      attr_accessor :feature_pattern
      attr_accessor :cucumber_opts
      attr_accessor :rcov
      attr_accessor :rcov_opts

      # Define a task
      def initialize(task_name = "features", desc = "Run Features with Cucumber")
        @task_name, @desc = task_name, desc
        @libs = []
        @rcov_opts = %w{--rails --exclude osx\/objc,gems\/}

        yield self if block_given?

        @feature_pattern = "features/**/*.feature" if feature_pattern.nil? && feature_list.nil?
        @step_pattern    = "features/**/*.rb"      if step_pattern.nil? && step_list.nil?
        @binary        ||= File.expand_path(File.dirname(__FILE__) + '/../../../bin/cucumber')
        define_task
      end

      def define_task
        desc @desc
        task @task_name do
          ruby(arguments_for_ruby_execution.join(" ")) # ruby(*args) is broken on Windows
        end
      end

      def arguments_for_ruby_execution(task_args = nil)
        lib_args     = ['"%s"' % ([LIB] + libs).join(File::PATH_SEPARATOR)]
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

      def define_task
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
