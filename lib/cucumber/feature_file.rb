require 'cucumber/parser/natural_language'
require 'cucumber/parser/gherkin_builder'

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
    def parse(step_mother, options)
      filters = {
        :lines => @lines,
        :name_regexen => options[:name_regexen],
        :tag_expression => options[:tag_expression]
      }
      return gherkin_parse(filters) if ENV['GHERKIN']

      language = Parser::NaturalLanguage.get(step_mother, (lang || 'en'))
      language.parse(source, @path, filters)
    end

    def gherkin_parse(filters)
      require 'gherkin/parser/filter_listener'
      require 'gherkin/parser/parser'
      require 'gherkin/i18n_lexer'

      builder         = Cucumber::Parser::GherkinBuilder.new
      filter_listener = Gherkin::Parser::FilterListener.new(builder, filters)
      parser          = Gherkin::Parser::Parser.new(filter_listener, true, "root")
      lexer           = Gherkin::I18nLexer.new(parser, false)
      lexer.scan(source)
      ast = builder.ast
      ast.language = lexer.i18n_language
      ast.file = @path
      ast
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
    
    def lang
      # TODO: Gherkin has logic for this. Remove.
      line_one = source.split(/\n/)[0]
      if line_one =~ LANGUAGE_PATTERN
        $1.strip
      else
        nil
      end
    end
  end
end