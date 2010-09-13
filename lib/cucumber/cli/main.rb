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
require 'cucumber/formatter/color_io'
require 'cucumber/cli/configuration'
require 'cucumber/cli/drb_client'

if defined?(Spork::TestFramework::Cucumber)
  class Spork::TestFramework::Cucumber < Spork::TestFramework
    def run_tests(argv, stderr, stdout)
      ::Cucumber::Cli::Main.new(argv, stdout, stderr).execute!
    end
  end
end

module Cucumber
  module Cli
    class Main
      class << self
        def execute(args)
          new(args).execute!
        end
      end

      def initialize(args, out_stream = STDOUT, error_stream = STDERR)
        @args         = args
        if Cucumber::WINDOWS_MRI
          @out_stream   = out_stream == STDOUT ? Formatter::ColorIO.new(Kernel, STDOUT) : out_stream
        else
          @out_stream   = out_stream
        end

        @error_stream = error_stream
        @configuration = nil
      end

      def execute!(legacy_step_mother = nil)
        if legacy_step_mother
          warn("Passing a step_mother to #execute! is deprecated, and has been ignored: #{caller[0]}")
        end

        trap_interrupt
        return @drb_output if run_drb_client
        
        runtime = Runtime.new(configuration)
        runtime.run!
        runtime.results.failure?
      rescue ProfilesNotDefinedError, YmlLoadError, ProfileNotFound => e
        @error_stream.puts e.message
        true
      end

      def configuration
        return @configuration if @configuration

        @configuration = Configuration.new(@out_stream, @error_stream)
        @configuration.parse!(@args)
        Cucumber.logger = @configuration.log
        @configuration
      end

      private
      
      def run_drb_client
        return false unless configuration.drb?
        @drb_output = DRbClient.run(@args, @error_stream, @out_stream, configuration.drb_port)
        true
      rescue DRbClientError => e
        @error_stream.puts "WARNING: #{e.message} Running features locally:"
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
