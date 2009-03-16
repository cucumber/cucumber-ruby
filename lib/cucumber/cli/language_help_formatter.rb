require 'cucumber/formatter/pretty'

module Cucumber
  module Cli
    class LanguageHelpFormatter < Formatter::Pretty
      INCOMPLETE = %{
The Cucumber grammar has evolved since this translation was written.
Please help us complete the translation by translating the missing words in

#{Cucumber::LANGUAGE_FILE}

Then contribute back to the Cucumber project. Details here:
http://wiki.github.com/aslakhellesoy/cucumber/spoken-languages
}

      def self.list_languages(io)
        raw = Cucumber::LANGUAGES.keys.sort.map do |lang|
          [lang, Cucumber::LANGUAGES[lang]['name'], Cucumber::LANGUAGES[lang]['native']]
        end
        table = Ast::Table.new(raw)
        new(nil, io, {:check_lang=>true}, '').visit_multiline_arg(table)
      end

      def self.list_keywords(io, lang)
        raw = Cucumber::KEYWORD_KEYS.map do |key|
          [key, Cucumber::LANGUAGES[lang][key]]
        end
        table = Ast::Table.new(raw)
        new(nil, io, {:incomplete => Cucumber.language_incomplete?(lang)}, '').visit_multiline_arg(table)
      end

      def visit_multiline_arg(table)
        if @options[:incomplete]
          @io.puts(format_string(INCOMPLETE, :failed))
        end
        super
      end

      def visit_table_row(table_row)
        @col = 1
        super
      end

      def visit_table_cell_value(value, width, status)
        if @col == 1
          if(@options[:check_lang])
            @incomplete = Cucumber.language_incomplete?(value)
          end
          status = :comment 
        elsif @incomplete
          status = :undefined
        end
        
        @col += 1
        super(value, width, status)
      end
    end
  end
end