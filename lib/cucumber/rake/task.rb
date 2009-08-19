require 'cucumber/platform'

module Cucumber
  module Rake
    # Defines a Rake task for running features.
    #
    # The simplest use of it goes something like:
    #
    #   Cucumber::Rake::Task.new
    #
    # This will define a task named <tt>cucumber</tt> described as 'Run Cucumber features'. 
    # It will use steps from 'features/**/*.rb' and features in 'features/**/*.feature'.
    #
    # To further configure the task, you can pass a block:
    #
    #   Cucumber::Rake::Task.new do |t|
    #     t.cucumber_opts = %w{--format progress}
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
      class InProcessCucumberRunner #:nodoc:
        attr_reader :args
        
        def initialize(libs, cucumber_opts, feature_files)
          raise "libs must be an Array when running in-process" unless Array === libs
          libs.reverse.each{|lib| $LOAD_PATH.unshift(lib)}
          @args = (
            cucumber_opts + 
            feature_files
          ).flatten.compact
        end
        
        def run
          require 'cucumber/cli/main'
          failure = Cucumber::Cli::Main.execute(args)
          raise "Cucumber failed" if failure
        end
      end
      
      class ForkedCucumberRunner #:nodoc:
        attr_reader :args
        
        def initialize(libs, cucumber_bin, cucumber_opts, feature_files)
          @args = (
            ['-I'] + load_path(libs) + 
            quoted_binary(cucumber_bin) + 
            cucumber_opts + 
            feature_files
          ).flatten
        end

        def load_path(libs)
          ['"%s"' % libs.join(File::PATH_SEPARATOR)]
        end

        def quoted_binary(cucumber_bin)
          ['"%s"' % cucumber_bin]
        end

        def run
          ruby(args.join(" ")) # ruby(*args) is broken on Windows
        end
      end

      class RCovCucumberRunner < ForkedCucumberRunner #:nodoc:
        def initialize(libs, cucumber_bin, cucumber_opts, feature_files, rcov_opts)
          @args = (
            ['-I'] + load_path(libs) + 
            ['-S', 'rcov'] + rcov_opts +
            quoted_binary(cucumber_bin) + 
            ['--'] + 
            cucumber_opts + 
            feature_files
          ).flatten
        end
      end

      LIB = File.expand_path(File.dirname(__FILE__) + '/../..') #:nodoc:

      # TODO: remove depreated accessors for 0.4.0
      def self.deprecate_accessor(attribute) #:nodoc:
        attr_reader attribute
        class_eval <<-EOF, __FILE__, __LINE__ + 1
          def #{attribute}=(value)
            @#{attribute} = value
            warn("\nWARNING: Cucumber::Rake::Task##{attribute} is deprecated and will be removed in 0.4.0.  Please use profiles for complex settings: http://wiki.github.com/aslakhellesoy/cucumber/using-rake#profiles\n")
          end
        EOF
      end

      # Directories to add to the Ruby $LOAD_PATH
      attr_accessor :libs

      # Name of the cucumber binary to use for running features. Defaults to Cucumber::BINARY
      attr_accessor :binary

      # Array of paths to specific step definition files to use
      deprecate_accessor :step_list

      # File pattern for finding step definitions. Defaults to 
      # 'features/**/*.rb'.
      deprecate_accessor :step_pattern

      # Array of paths to specific features to run. 
      deprecate_accessor :feature_list

      # File pattern for finding features to run. Defaults to 
      # 'features/**/*.feature'. Can be overridden by the FEATURE environment variable.
      deprecate_accessor :feature_pattern

      # Extra options to pass to the cucumber binary. Can be overridden by the CUCUMBER_OPTS environment variable.
      # It's recommended to pass an Array, but if it's a String it will be #split by ' '.
      attr_accessor :cucumber_opts
      def cucumber_opts=(opts) #:nodoc:
        @cucumber_opts = String === opts ? opts.split(' ') : opts
      end

      # Run cucumber with RCov? Defaults to false. If you set this to
      # true, +fork+ is implicit.
      attr_accessor :rcov

      # Extra options to pass to rcov.
      # It's recommended to pass an Array, but if it's a String it will be #split by ' '.
      attr_accessor :rcov_opts
      def rcov_opts=(opts) #:nodoc:
        @rcov_opts = String === opts ? opts.split(' ') : opts
      end

      # Whether or not to fork a new ruby interpreter. Defaults to true. You may gain
      # some startup speed if you set it to false, but this may also cause issues with
      # your load path and gems.
      attr_accessor :fork

      # Define what profile to be used.  When used with cucumber_opts it is simply appended to it. Will be ignored when CUCUMBER_OPTS is used.
      attr_accessor :profile
      def profile=(profile) #:nodoc:
        @profile = profile
        unless feature_list
          # TODO: remove once we completely remove these from the rake task.
          @step_list = []
          @feature_list = [] # Don't use accessor to avoid deprecation warning.
        end
      end

      # Define Cucumber Rake task
      def initialize(task_name = "cucumber", desc = "Run Cucumber features")
        @task_name, @desc = task_name, desc
        @fork = true
        @libs = ['lib']
        @rcov_opts = %w{--rails --exclude osx\/objc,gems\/}

        yield self if block_given?

        @feature_pattern = "features/**/*.feature" if feature_pattern.nil? && feature_list.nil?
        @step_pattern    = "features/**/*.rb"      if step_pattern.nil? && step_list.nil?

        @binary = binary.nil? ? Cucumber::BINARY : File.expand_path(binary)
        @libs.insert(0, LIB) if binary == Cucumber::BINARY

        define_task
      end

      def define_task #:nodoc:
        desc @desc
        task @task_name do
          runner.run
        end
      end

      def runner(task_args = nil) #:nodoc:
        cucumber_opts = [(ENV['CUCUMBER_OPTS'] ? ENV['CUCUMBER_OPTS'].split(/\s+/) : nil) || cucumber_opts_with_profile]
        if(@rcov)
          RCovCucumberRunner.new(libs, binary, cucumber_opts, feature_files(task_args), rcov_opts)
        elsif(@fork)
          ForkedCucumberRunner.new(libs, binary, cucumber_opts, feature_files(task_args))
        else
          InProcessCucumberRunner.new(libs, cucumber_opts, feature_files(task_args))
        end
      end

      def cucumber_opts_with_profile #:nodoc:
        @profile ? [cucumber_opts, '--profile', @profile] : cucumber_opts
      end

      def feature_files(task_args = nil) #:nodoc:
        if ENV['FEATURE']
          FileList[ ENV['FEATURE'] ]
        else
          result = []
          result += feature_list.to_a if feature_list
          result += FileList[feature_pattern].to_a if feature_pattern
          result = make_command_line_safe(result)
          FileList[result]
        end
      end

      def step_files(task_args = nil) #:nodoc:
        if ENV['STEPS']
          FileList[ ENV['STEPS'] ]
        else
          result = []
          result += Array(step_list) if step_list
          result += Array(FileList[step_pattern]) if step_pattern
          FileList[result]
        end
      end

      private
      def make_command_line_safe(list)
        list.map{|string| string.gsub(' ', '\ ')}
      end
    end

    class FeatureTask < Task

      def initialize(task_name = "feature", desc = "Run a specified feature with Cucumber.  #{task_name}[feature_name]")
        super(task_name, desc)
      end

      def define_task #:nodoc:
        desc @desc
        task @task_name, :feature_name do |t, args|
          runner(args).run
        end
      end

      def feature_files(task_arguments) #:nodoc:
        FileList[File.join("features", "**", "#{task_arguments[:feature_name]}.feature")]
      end

    end

  end
end
