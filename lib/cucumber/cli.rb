require 'optparse'
require 'cucumber/step_methods'
require 'cucumber/ruby_tree'

module Cucumber
  class CLI
    class << self
      attr_writer :step_mother, :stories
    
      def execute
        parse(ARGV).execute!(@step_mother, @stories)
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
      @options = { :require => nil, :lang => 'en', :format => 'pretty', :dry_run => false }
      @args.options do |opts|
        opts.banner = "Usage: cucumber [options] FILES|DIRS"
        opts.on("-r LIBRARY|DIR", "--require LIBRARY|DIR", "Require files before executing the stories.",
          "If this option is not specified, all *.rb files that",
          "are siblings or below the stories will be autorequired") do |v|
          @options[:require] ||= []
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
    
    def execute!(step_mother, stories)
      $executor = Executor.new(formatter, step_mother)
      require_files
      load_plain_text_stories(stories)
#      $executor.visit_stories(stories)
      $executor.visit_stories(stories)
      exit 1 if $executor.failed
    end
    
  private
    
    def require_files
      require "cucumber/parser/story_parser_#{@options[:lang]}"
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
    
    def load_plain_text_stories(stories)
      parser = Parser::StoryParser.new
      @files.each do |f|
        stories << Parser::StoryNode.parse(f, parser)
      end
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
# TODO: Hook in a RubyStories object on toplevel for pure ruby stories
extend Cucumber::StepMethods
Cucumber::CLI.step_mother = step_mother

extend(Cucumber::RubyTree)
Cucumber::CLI.stories = stories