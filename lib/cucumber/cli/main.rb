require 'optparse'
require 'cucumber'
require 'ostruct'
require 'cucumber/parser'
require 'cucumber/formatter/color_io'
require 'cucumber/cli/language_help_formatter'
require 'cucumber/cli/configuration'
require 'cucumber/cli/drb_client'

module Cucumber
  module Cli
    class Main
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
        if configuration.drb?
          if DRbClient.run(@args, @error_stream, @out_stream)
            return false
          else
            @error_stream.puts "WARNING: No DRb server is running. Running features locally:"
            configuration.parse!(@args)
          end
        end
        configuration.load_language
        step_mother.options = configuration.options

        require_files
        enable_diffing
      
        features = load_plain_text_features

        visitor = configuration.build_formatter_broadcaster(step_mother)
        step_mother.visitor = visitor # Needed to support World#announce
        visitor.visit_features(features)

        failure = if configuration.wip?
          step_mother.scenarios(:passed).any?
        else
          step_mother.scenarios(:failed).any? || 
          (configuration.strict? && step_mother.steps(:undefined).any?)
        end
      end

      def load_plain_text_features
        features = Ast::Features.new
        parser = Parser::FeatureParser.new

        verbose_log("Features:")
        configuration.feature_files.each do |f|
          feature = parser.parse_file(f, configuration.options)
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

      def load_files
        each_lib{|lib| load(lib)}
      end

      private

      def require_files
        each_lib{|lib| require lib}
      end

      def each_lib
        requires = configuration.files_to_require
        verbose_log("Ruby files required:")
        verbose_log(requires.map{|lib| "  * #{lib}"}.join("\n"))
        requires.each do |lib|
          begin
            yield lib
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
    
    end
  end
end

Cucumber::Cli::Main.step_mother = self
