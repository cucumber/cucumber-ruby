require 'cucumber/parser/i18n/language'
require 'cucumber/filter'

module Cucumber
  class FeatureFile
    FILE_COLON_LINE_PATTERN = /^([\w\W]*?):([\d:]+)$/

    # The +file+ argument can ba a path or a path:line1:line2 etc.
    def initialize(file)
      _, @path, @lines = *FILE_COLON_LINE_PATTERN.match(file)
      if @path
        @lines = @lines.split(':').map { |line| line.to_i }
      else
        @path = file
      end
    end
    
    def parse(options)
      filter = Filter.new(@lines, options)
      language = Parser::I18n::Language[lang || options[:lang]]
      language.parse_file(@path, filter)
    end
    
    def lang
      line_one = IO.read(@path).split(/\n/)[0]
      if line_one =~ /language:\s*(.*)/
        $1.strip
      else
        nil
      end
    end
  end
end