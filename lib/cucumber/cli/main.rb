require 'optparse'
require 'cucumber'
require 'ostruct'
require 'cucumber/parser'
require 'cucumber/formatter'
require 'cucumber/cli/language_help_formatter'
require 'cucumber/cli/configuration'

module Cucumber
  module Cli
    class Main
      class << self
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
        configuration.load_language
        step_mother.options = configuration.options

        require_files
        enable_diffing
      
        features = load_plain_text_features

        visitor = configuration.build_formatter_broadcaster(step_mother)
        step_mother.visitor = visitor # Needed to support World#announce
        visitor.visit_features(features)

        failure = step_mother.steps(:failed).any? || 
          (configuration.strict? && step_mother.steps(:undefined).any?)

        Kernel.exit(failure ? 1 : 0)
      end

      def load_plain_text_features
        features = Ast::Features.new
        parser = Parser::FeatureParser.new

        verbose_log("Features:")
        configuration.feature_files.each do |f|
          features.add_feature(parser.parse_file(f))
          verbose_log("  * #{f}")
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

      private
    
      def require_files
        verbose_log("Ruby files required:")
        configuration.files_to_require.each do |lib|
          begin
            require lib
            verbose_log("  * #{lib}")
          rescue LoadError => e
            e.message << "\nFailed to load #{lib}"
            raise e
          end
        end
        verbose_log("\n")
      end

      def verbose_log(string)
        @out_stream.puts(string) if configuration.verbose?
      end

      def enable_diffing
        if configuration.diff_enabled? && defined?(::Spec)
          require 'spec/expectations/differs/default'
          options = OpenStruct.new(:diff_format => :unified, :context_lines => 3)
          ::Spec::Expectations.differ = ::Spec::Expectations::Differs::Default.new(options)
        end
      end
    
    end
  end
end

Cucumber::Cli::Main.step_mother = self
