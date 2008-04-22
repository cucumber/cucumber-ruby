require 'optparse'

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
    end
    
    def parse_options!
      @options = { :lang => 'en' }
      OptionParser.new(@args) do |opts|
        opts.banner = "Usage: cucumber [options] files"
        opts.on("-l LANG", "--language LANG", "Specify language for stories (Default: #{@options[:lang]})") do |v|
          @options[:lang] = v
        end
        opts.on("-f FORMAT", "--format FORMAT", "How to format stories") do |v|
          @options[:format] = v
        end
      end.parse!
      @files = @args
    end
    
    def execute!
      require "cucumber/parser/story_parser_#{@options[:lang]}"
      StoryRunner.new.execute(@files, handler)
    end
    
  private
    
    def handler
      require 'cucumber/pretty_printer'
      handler = PrettyPrinter.new
    end
    
  end
end