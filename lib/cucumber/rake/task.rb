# frozen_string_literal: true

require 'rake/dsl_definition'

require_relative '../gherkin/formatter/ansi_escapes'
require_relative '../platform'
require_relative 'forked_cucumber_runner'
require_relative 'in_process_cucumber_runner'

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
    # See the attributes for additional configuration possibilities.
    class Task
      include Cucumber::Gherkin::Formatter::AnsiEscapes
      include ::Rake::DSL if defined?(::Rake::DSL)

      # Name of the cucumber binary to use for running features. Defaults to Cucumber::BINARY
      attr_accessor :binary

      # Whether or not to run with bundler (bundle exec). Setting this to false may speed
      # up the execution. The default value is true if Bundler is installed and you have
      # a Gemfile, false otherwise.
      #
      # Note that this attribute has no effect if you don't run in forked mode.
      attr_accessor :bundler

      # Extra options to pass to the cucumber binary. Can be overridden by the CUCUMBER_OPTS environment variable.
      # It's recommended to pass an Array, but if it's a String it will be #split by ' '.
      attr_reader :cucumber_opts

      # Whether or not to fork a new ruby interpreter. Defaults to true. You may gain
      # some startup speed if you set it to false, but this may also cause issues with
      # your load path and gems.
      attr_accessor :fork

      # Directories to add to the Ruby $LOAD_PATH
      attr_accessor :libs

      # Define what profile to be used.  When used with cucumber_opts it is simply appended
      # to it. Will be ignored when CUCUMBER_OPTS is used.
      attr_accessor :profile

      # Name of the running task
      attr_reader :task_name

      def initialize(task_name = 'cucumber', desc = 'Run Cucumber features')
        @task_name = task_name
        @desc = desc
        @fork = true
        @libs = ['lib']
        @rcov_opts = %w[--rails --exclude osx\/objc,gems\/]
        yield self if block_given?
        @binary = binary.nil? ? Cucumber::BINARY : File.expand_path(binary)
        define_task
      end

      def cucumber_opts=(opts) # :nodoc:
        unless opts.instance_of? String
          @cucumber_opts = opts
          return
        end

        @cucumber_opts = opts.split(' ')
        return if @cucumber_opts.length <= 1

        $stderr.puts 'WARNING: consider using an array rather than a space-delimited string with cucumber_opts to avoid undesired behavior.'
      end

      def cucumber_opts_with_profile # :nodoc:
        Array(cucumber_opts).concat(Array(@profile).flat_map { |p| ['--profile', p] })
      end

      def define_task # :nodoc:
        desc @desc
        task @task_name do
          runner.run
        end
      end

      def feature_files # :nodoc:
        make_command_line_safe(FileList[ENV['FEATURE'] || []])
      end

      def make_command_line_safe(list)
        list.map { |string| string.gsub(' ', '\ ') }
      end

      def runner(_task_args = nil) # :nodoc:
        cucumber_opts = [ENV['CUCUMBER_OPTS']&.split(/\s+/) || cucumber_opts_with_profile]
        return ForkedCucumberRunner.new(libs, binary, cucumber_opts, bundler, feature_files) if fork

        InProcessCucumberRunner.new(libs, cucumber_opts, feature_files)
      end
    end
  end
end
