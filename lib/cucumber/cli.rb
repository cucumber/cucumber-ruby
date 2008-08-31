require 'optparse'
require 'cucumber'

module Cucumber
  class CLI
    class << self
      attr_writer :step_mother, :features
    
      def execute
        @execute_called = true
        parse(ARGV).execute!(@step_mother, @features)
      end
      
      def execute_called?
        @execute_called
      end

      def parse(args)
        cli = new(args)
        cli.parse_options!
        cli
      end
    end
    
    FORMATS = %w{pretty progress html}

    def initialize(args)
      @args = args.dup
      @args.extend(OptionParser::Arguable)
    end
    
    def parse_options!
      @options = { :require => nil, :lang => 'en', :format => 'pretty', :dry_run => false }
      @args.options do |opts|
        opts.banner = "Usage: cucumber [options] FILES|DIRS"
        opts.on("-r LIBRARY|DIR", "--require LIBRARY|DIR", "Require files before executing the features.",
          "If this option is not specified, all *.rb files that",
          "are siblings or below the features will be autorequired") do |v|
          @options[:require] ||= []
          @options[:require] << v
        end
        opts.on("-l LINE", "--line LINE", "Only execute the scenario at the given line") do |v|
          @options[:line] = v
        end
        opts.on("-a LANG", "--language LANG", "Specify language for features (Default: #{@options[:lang]})",
          "Available languages: #{Cucumber.languages.join(", ")}") do |v|
          @options[:lang] = v
        end
        opts.on("-f FORMAT", "--format FORMAT", "How to format features (Default: #{@options[:format]})",
          "Available formats: #{FORMATS.join(", ")}") do |v|
          unless FORMATS.index(v) 
            STDERR.puts "Invalid format: #{v}\n"
            STDERR.puts opts.help
            exit 1
          end
          @options[:format] = v
        end
        opts.on("-d", "--dry-run", "Invokes formatters without executing the steps.") do
          @options[:dry_run] = true
        end
        opts.on_tail("--version", "Show version") do
          puts VERSION::STRING
          exit
        end
        opts.on_tail("--help", "You're looking at it") do
          puts opts.help
          exit
        end
      end.parse!
      
      # Whatever is left after option parsing
      @files = @args.map do |path|
        path = path.gsub(/\\/, '/') # In case we're on windows. Globs don't work with backslashes.
        File.directory?(path) ? Dir["#{path}/**/*.feature"] : path
      end.flatten
    end
    
    def execute!(step_mother, features)
      Cucumber.load_language(@options[:lang])
      $executor = Executor.new(formatter(step_mother), step_mother)
      require_files
      load_plain_text_features(features)
      $executor.line = @options[:line].to_i if @options[:line]
      $executor.visit_features(features)
      exit 1 if $executor.failed
    end
    
  private
    
    # Requires files - typically step files and ruby feature files.
    def require_files
      ARGV.clear # Shut up RSpec
      require "cucumber/treetop_parser/feature_#{@options[:lang]}"
      require "cucumber/treetop_parser/feature_parser"

      requires = @options[:require] || @args.map{|f| File.directory?(f) ? f : File.dirname(f)}.uniq
      libs = requires.map do |path|
        path = path.gsub(/\\/, '/') # In case we're on windows. Globs don't work with backslashes.
        File.directory?(path) ? Dir["#{path}/**/*.rb"] : path
      end.flatten
      libs.each do |lib|
        begin
          require lib
        rescue LoadError => e
          e.message << "\nFailed to load #{lib}"
          raise e
        end
      end
    end
    
    def load_plain_text_features(features)
      parser = TreetopParser::FeatureParser.new
      @files.each do |f|
        features << parser.parse_feature(f)
      end
    end
    
    def formatter(step_mother)
      case @options[:format]
      when 'pretty'
        Formatters::PrettyFormatter.new(STDOUT)
      when 'progress'
        Formatters::ProgressFormatter.new(STDOUT)
      when 'html'
        Formatters::HtmlFormatter.new(STDOUT, step_mother)
      end
    end
    
  end
end

extend Cucumber::StepMethods
Cucumber::CLI.step_mother = step_mother

extend(Cucumber::Tree)
Cucumber::CLI.features = features

at_exit do
  Cucumber::CLI.execute unless Cucumber::CLI.execute_called?
end