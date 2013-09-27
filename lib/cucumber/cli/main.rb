begin
  require 'gherkin'
rescue LoadError
  require 'rubygems'
  require 'gherkin'
end
require 'optparse'
require 'cucumber'
require 'logger'
require 'cucumber/parser'
require 'cucumber/feature_file'
require 'cucumber/cli/configuration'

module Cucumber
  module Cli
    class Main
      class << self
        def execute(args)
          new(args).execute!
        end
      end

      def initialize(args, stdin=STDIN, out=STDOUT, err=STDERR, kernel=Kernel)
        raise "args can't be nil" unless args
        raise "out can't be nil" unless out
        raise "err can't be nil" unless err
        raise "kernel can't be nil" unless kernel
        @args   = args
        @out    = out
        @err    = err
        @kernel = kernel
        @configuration = nil
      end

      def execute!(existing_runtime = nil)
        trap_interrupt

        runtime = if existing_runtime
          existing_runtime.configure(configuration)
          existing_runtime
        else
          Runtime.new(configuration)
        end

        runtime.run!
        runtime.write_stepdefs_json
        failure = runtime.results.failure? || Cucumber.wants_to_quit
        @kernel.exit(failure ? 1 : 0)
      rescue FileNotFoundException => e
        @err.puts(e.message)
        @err.puts("Couldn't open #{e.path}")
        @kernel.exit(1)
      rescue FeatureFolderNotFoundException => e
        @err.puts(e.message + ". Please create a #{e.path} directory to get started.")
        @kernel.exit(1)
      rescue ProfilesNotDefinedError, YmlLoadError, ProfileNotFound => e
        @err.puts(e.message)
      rescue SystemExit => e
        @kernel.exit(e.status)
      rescue Errno::EACCES, Errno::ENOENT => e
        @err.puts("#{e.message} (#{e.class})")
        @kernel.exit(1)
      rescue Exception => e
        @err.puts("#{e.message} (#{e.class})")
        @err.puts(e.backtrace.join("\n"))
        @kernel.exit(1)
      end

      def configuration
        return @configuration if @configuration

        @configuration = Configuration.new(@out, @err)
        @configuration.parse!(@args)
        Cucumber.logger = @configuration.log
        @configuration
      end

      private

      def trap_interrupt
        trap('INT') do
          exit!(1) if Cucumber.wants_to_quit
          Cucumber.wants_to_quit = true
          STDERR.puts "\nExiting... Interrupt again to exit immediately."
        end
      end
    end
  end
end
