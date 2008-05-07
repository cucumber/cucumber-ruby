require 'optparse'
require 'cucumber/step_methods'

include Cucumber::StepMethods

module Cucumber
  class CLI
    def self.execute
      parse(ARGV).execute!
    end
    
    def self.parse(args)
      cli = new(args)
      cli.parse_options!
      cli
    end

    def initialize(args)
      @args = args.dup
      @args.extend(OptionParser::Arguable)
    end
    
    def parse_options!
      @options = { :require => [], :lang => 'en', :dry_run => false }
      @args.options do |opts|
        opts.banner = "Usage: cucumber [options] FILES|DIRS"
        opts.on("-r LIBRARY|DIR", "--require LIBRARY|DIR", "Require the library, before executing your stories") do |v|
          @options[:require] << v
        end
        opts.on("-l LANG", "--language LANG", "Specify language for stories (Default: #{@options[:lang]})") do |v|
          @options[:lang] = v
        end
        opts.on("-f FORMAT", "--format FORMAT", "How to format stories") do |v|
          @options[:format] = v
        end
        opts.on("-d", "--dry-run", "Invokes formatters without executing the steps.") do
          @options[:dry_run] = true
        end
      end.parse!
      # Whatever is left after option parsing
      @files = @args.map{|path| File.directory?(path) ? Dir["#{path}/**/*.story"] : path}.flatten
    end
    
    def execute!
      require "cucumber/parser/story_parser_#{@options[:lang]}"
      $executor = Executor.new(formatter)
      libs = @options[:require].map{|path| File.directory?(path) ? Dir["#{path}/**/*.rb"] : path}.flatten
      libs.each{|lib| require lib}
      
      stories.each do |story|
        story.accept($executor)
      end
    end
    
  private
    
    def stories
      parser = Parser::StoryParser.new
      @files.map do |file|
        story = parser.parse(IO.read(file))
        if story.nil?
          STDERR.puts(parser.compile_error(file))
          exit(1)
        end
        story.file = file
        story
      end
    end
    
    def formatter
      # TODO: use the -f flag
      require 'cucumber/progress_formatter'
      ProgressFormatter.new(STDOUT)
    end
    
  end
end