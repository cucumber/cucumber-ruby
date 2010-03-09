require 'optparse'
require 'cucumber'
require 'ostruct'
require 'logger'
require 'cucumber/parser'
require 'cucumber/feature_file'
require 'cucumber/formatter/color_io'
require 'cucumber/cli/configuration'
require 'cucumber/cli/drb_client'

module Cucumber
  module Cli
    class Main
      class << self
        def step_mother
          @step_mother ||= StepMother.new
        end

        def execute(args)
          new(args).execute!(step_mother)
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

      def execute!(step_mother)
        trap_interrupt
        if configuration.drb?
          begin
            return DRbClient.run(@args, @error_stream, @out_stream, configuration.drb_port)
          rescue DRbClientError => e
            @error_stream.puts "WARNING: #{e.message} Running features locally:"
          end
        end
        step_mother.options = configuration.options
        step_mother.log = configuration.log

        step_mother.load_code_files(configuration.support_to_load)
        step_mother.after_configuration(configuration)
        features = step_mother.load_plain_text_features(configuration.feature_files)
        step_mother.load_code_files(configuration.step_defs_to_load)

        enable_diffing

        tag_excess = tag_excess(features)
        configuration.options[:tag_excess] = tag_excess # Hack to make it available in console.rb - later: stick on Run instance.

        runner = configuration.build_runner(step_mother, @out_stream)
        step_mother.visitor = runner # Needed to support World#announce
        
        runner.visit_features(features)

        failure = if tag_excess.any?
          true
        elsif configuration.wip?
          step_mother.scenarios(:passed).any?
        else
          step_mother.scenarios(:failed).any? ||
          (configuration.strict? && (step_mother.steps(:undefined).any? || step_mother.steps(:pending).any?))
        end
      rescue ProfilesNotDefinedError, YmlLoadError, ProfileNotFound => e
        @error_stream.puts e.message
        true
      end

      def tag_excess(features)
        configuration.options[:tag_expression].limits.map do |tag_name, tag_limit|
          tag_locations = features.tag_locations(tag_name)
          if tag_limit && (tag_locations.length > tag_limit)
            [tag_name, tag_limit, tag_locations]
          else
            nil
          end
        end.compact
      end

      def configuration
        return @configuration if @configuration

        @configuration = Configuration.new(@out_stream, @error_stream)
        @configuration.parse!(@args)
        @configuration
      end

      private

      def enable_diffing
        if configuration.diff_enabled?
          begin
            require 'spec/expectations'
            begin
              require 'spec/runner/differs/default' # RSpec >=1.2.4
            rescue ::LoadError
              require 'spec/expectations/differs/default' # RSpec <=1.2.3
            end
            options = OpenStruct.new(:diff_format => :unified, :context_lines => 3)
            ::Spec::Expectations.differ = ::Spec::Expectations::Differs::Default.new(options)
          rescue ::LoadError => ignore
          end
        end
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
