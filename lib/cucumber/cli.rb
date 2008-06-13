require 'optparse'
require 'cucumber/step_methods'

module Cucumber
  class CLI
    class << self
      attr_writer :step_mother
    
      def execute
        parse(ARGV).execute!(@step_mother)
      end

      def parse(args)
        cli = new(args)
        cli.parse_options!
        cli
      end
    end

    def initialize(args)
      @args = args.dup
      @args.extend(OptionParser::Arguable)
    end
    
    def parse_options!
      @options = { :require => [], :lang => 'en', :format => 'progress', :dry_run => false }
      @args.options do |opts|
        opts.banner = "Usage: cucumber [options] FILES|DIRS"
        opts.on("-r LIBRARY|DIR", "--require LIBRARY|DIR", "Require the library, before executing your stories") do |v|
          @options[:require] << v
        end
        opts.on("-l LANG", "--language LANG", "Specify language for stories (Default: #{@options[:lang]})") do |v|
          @options[:lang] = v
        end
        opts.on("-f FORMAT", "--format FORMAT", "How to format stories (Default: #{@options[:format]})") do |v|
          @options[:format] = v
        end
        opts.on("-d", "--dry-run", "Invokes formatters without executing the steps.") do
          @options[:dry_run] = true
        end
      end.parse!
      # Whatever is left after option parsing
      @files = @args.map do |path|
        path = path.gsub(/\\/, '/') # In case we're on windows. Globs don't work with backslashes.
        File.directory?(path) ? Dir["#{path}/**/*.story"] : path
      end.flatten
    end
    
    def execute!(step_mother)
      require "cucumber/parser/story_parser_#{@options[:lang]}"
      $executor = Executor.new(formatter, step_mother)
      libs = @options[:require].map{|path| File.directory?(path) ? Dir["#{path}/**/*.rb"] : path}.flatten
      libs.each do |lib|
        begin
          require lib
        rescue LoadError => e
          e.message << "\nFailed to load #{lib}"
          raise e
        end
      end
      
      $executor.visit_stories(stories)
    end
    
  private
    
    def stories
      Parser::StoriesNode.new(@files, Parser::StoryParser.new)
    end
    
    def formatter
      klass = {
        'progress' => Formatters::ProgressFormatter,
        'html'     => Formatters::HtmlFormatter,
        'pretty'   => Formatters::PrettyFormatter,
      }[@options[:format]]
      klass.new(STDOUT)
    end
    
  end
end

# Hook the toplevel StepMother to the CLI
extend Cucumber::StepMethods
Cucumber::CLI.step_mother = step_mother
