require 'cucumber/parser/gherkin_builder'
require 'gherkin/formatter/filter_formatter'
require 'gherkin/formatter/tag_count_formatter'
require 'gherkin/parser/parser'
require 'gherkin/i18n_lexer'

module Cucumber
  class FeatureFile
    FILE_COLON_LINE_PATTERN = /^([\w\W]*?):([\d:]+)$/ #:nodoc:
    LANGUAGE_PATTERN = /language:\s*(.*)/ #:nodoc:

    # The +uri+ argument is the location of the source. It can ba a path 
    # or a path:line1:line2 etc. If +source+ is passed, +uri+ is ignored.
    def initialize(uri, source=nil)
      @source = source
      _, @path, @lines = *FILE_COLON_LINE_PATTERN.match(uri)
      if @path
        @lines = @lines.split(':').map { |line| line.to_i }
      else
        @path = uri
      end
    end
    
    # Parses a file and returns a Cucumber::Ast
    # If +options+ contains tags, the result will
    # be filtered.
    def parse(options, tag_counts)
      filters = @lines || options.filters

      builder             = Cucumber::Parser::GherkinBuilder.new
      filter_formatter    = filters.empty? ? builder : Gherkin::Formatter::FilterFormatter.new(builder, filters)
      tag_count_formatter = Gherkin::Formatter::TagCountFormatter.new(filter_formatter, tag_counts)
      parser              = Gherkin::Parser::Parser.new(tag_count_formatter, true, "root", false)

      begin
        parser.parse(source, @path, 0)
        ast = builder.ast
        return nil if ast.nil? # Filter caused nothing to match
        ast.language = parser.i18n_language
        ast.file = @path
        ast
      rescue Gherkin::LexingError, Gherkin::Parser::ParseError => e
        e.message.insert(0, "#{@path}: ")
        raise e
      end
    end

    def source
      @source ||= if @path =~ /^http/
        require 'open-uri'
        open(@path).read
      else
        begin
          File.open(@path, Cucumber.file_mode('r')).read 
        rescue Errno::EACCES => e
          p = File.expand_path(@path)
          e.message << "\nCouldn't open #{p}"
          raise e
        end
      end
    end
    
    private
    
    # Special PML markup that we want to filter out.
    CO = %{\\s*<(label|callout)\s+id=".*?"\s*/>\\s*}
    C_CALLOUT = %r{/\*#{CO}\*/|//#{CO}}o
  end
end
