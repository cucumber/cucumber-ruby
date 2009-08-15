require 'optparse'
require 'cucumber'
require 'ostruct'
require 'cucumber/parser'
require 'cucumber/feature_file'
require 'cucumber/formatter/color_io'
require 'cucumber/cli/language_help_formatter'
require 'cucumber/cli/configuration'
require 'cucumber/cli/drb_client'

module Cucumber
  module Cli
    class Main
      FAILURE = 1

      class << self
        def step_mother
          @step_mother
        end

        def step_mother=(step_mother)
          @step_mother = step_mother
          @step_mother.extend(StepMother)
          @step_mother.snippet_generator = StepDefinition
        end

        def execute(args)
          new(args).execute!(@step_mother)
        end
      end

      def initialize(args, out_stream = STDOUT, error_stream = STDERR)
        @args         = args
        @out_stream   = out_stream == STDOUT ? Formatter::ColorIO.new : out_stream
        @error_stream = error_stream
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

        # Feature files must be loaded before files are required.
        # This is because i18n step methods are only aliased when
        # features are loaded. If we swap the order, the requires
        # will fail.
        features = load_plain_text_features
        load_step_defs
        enable_diffing

        visitor = configuration.build_formatter_broadcaster(step_mother)
        step_mother.visitor = visitor # Needed to support World#announce
        visitor.visit_features(features)

        failure = if exceeded_tag_limts?(features)
            FAILURE
          elsif configuration.wip?
            step_mother.scenarios(:passed).any?
          else
            step_mother.scenarios(:failed).any? ||
            (configuration.strict? && step_mother.steps(:undefined).any?)
          end
      rescue ProfilesNotDefinedError, YmlLoadError, ProfileNotFound => e
        @error_stream.puts e.message
        true
      end

      def exceeded_tag_limts?(features)
        exceeded = false
        configuration.options[:include_tags].each do |tag, limit|
          unless limit.nil?
            tag_count = features.tag_count(tag)
            if tag_count > limit.to_i
              exceeded = true
            end
          end
        end
        exceeded
      end

      def load_plain_text_features
        features = Ast::Features.new

        verbose_log("Features:")
        configuration.feature_files.each do |f|
          feature_file = FeatureFile.new(f)
          feature = feature_file.parse(configuration.options)
          if feature
            features.add_feature(feature)
            verbose_log("  * #{f}")
          end
        end
        verbose_log("\n"*2)
        features
      end

      def configuration
        return @configuration if @configuration

        @configuration = Configuration.new(@out_stream, @error_stream)
        @configuration.parse!(@args)
        @configuration
      end

      def verbose_log(string)
        @out_stream.puts(string) if configuration.verbose?
      end

      private

      def load_step_defs
        step_def_files = configuration.step_defs_to_load
        verbose_log("Step Definitions Files:")
        step_def_files.each do |step_def_file|
          load_step_def(step_def_file)
        end
      end

      def load_step_def(step_def_file)
        if loader = step_def_loader_for(step_def_file)
          verbose_log("  * #{step_def_file}")
          loader.load_step_def_file(self, step_def_file)
        end
      end

      def step_def_loader_for(step_def_file)
        @sted_def_loaders ||= {}
        if ext = File.extname(step_def_file)[1..-1]
          loader = @sted_def_loaders[ext]
          return nil if loader == :missing
          return loader if loader
          begin
            loader_class = configuration.constantize("Cucumber::Cli::#{ext.capitalize}StepDefLoader")
            return @sted_def_loaders[ext] = loader_class.new
          rescue LoadError
            @sted_def_loaders[ext] = :missing
            nil
          end
        end
        nil
      end

      def step_def_files
        main.verbose_log("Ruby files required:")
        main.verbose_log(requires.map{|lib| "  * #{lib}"}.join("\n"))
        requires.each do |lib|
          begin
            require lib
          rescue LoadError => e
            e.message << "\nFailed to load #{lib}"
            raise e
          end
        end
        main.verbose_log("\n")
      end

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
          exit!(1) if $cucumber_interrupted
          $cucumber_interrupted = true
          STDERR.puts "\nExiting... Interrupt again to exit immediately."
        end
      end
    end
  end
end

Cucumber::Cli::Main.step_mother = self
