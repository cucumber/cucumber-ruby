module Cucumber
  module Rake
    # Defines a task for running features.
    class Task
      LIB    = File.expand_path(File.dirname(__FILE__) + '/../..')
      BINARY = File.expand_path(File.dirname(__FILE__) + '/../../../bin/cucumber')

      attr_accessor :libs
      attr_accessor :step_list
      attr_accessor :step_pattern
      attr_accessor :feature_list
      attr_accessor :feature_pattern
      attr_accessor :cucumber_opts
      attr_accessor :rcov
      attr_accessor :rcov_opts
      
      # Define a task
      def initialize(task_name = "features", desc = "Run Features")
        @task_name, @desc = task_name, desc
        @libs = []
        @rcov_opts = %w{--rails --exclude osx\/objc,gems\/}

        yield self if block_given?

        @feature_pattern = "features/**/*.feature" if feature_pattern.nil? && feature_list.nil?
        @step_pattern =  "features/**/*.rb"    if step_pattern.nil? && step_list.nil?
        define_tasks
      end
    
      def define_tasks
        desc @desc
        task @task_name do
          lib_args     = ['"%s"' % ([LIB] + libs).join(File::PATH_SEPARATOR)]
          cucumber_bin = ['"%s"' % BINARY]
          cuc_opts     = [(ENV['CUCUMBER_OPTS'] || cucumber_opts)]

          step_files.each do |step_file|
            cuc_opts << '--require'
            cuc_opts << step_file
          end

          if rcov
            args = (['-I'] + lib_args + ['-S', 'rcov'] + rcov_opts + cucumber_bin + ['--'] + cuc_opts + feature_files).flatten
          else
            args = (['-I'] + lib_args + cucumber_bin + cuc_opts + feature_files).flatten
          end
          ruby(args.join(" ")) # ruby(*args) is broken on Windows
        end
      end


      def feature_files # :nodoc:
        if ENV['FEATURE']
          FileList[ ENV['FEATURE'] ]
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