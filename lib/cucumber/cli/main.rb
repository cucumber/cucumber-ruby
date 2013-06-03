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
require 'cucumber/cli/drb_client'

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
        return @drb_output if run_drb_client

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

      def run_drb_client
        return false unless configuration.drb?
        warn("Spork is no longer supported as of Cucumber 1.3.0. Please downgrade to version 1.2.5")
        @drb_output = DRbClient.run(@args, @err, @out, configuration.drb_port)
        true
      rescue DRbClientError => e
        @err.puts "WARNING: #{e.message} Running features locally:"
      end

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
