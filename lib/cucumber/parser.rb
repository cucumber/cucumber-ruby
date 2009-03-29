require 'erb'
require 'cucumber/platform'
require 'cucumber/ast'
require 'cucumber/parser/treetop_ext'
require 'cucumber/parser/table'

module Cucumber
  # Classes in this module parse feature files and translate the parse tree 
  # (concrete syntax tree) into an abstract syntax tree (AST) using
  # <a href="http://martinfowler.com/dslwip/EmbeddedTranslation.html">Embedded translation</a>.
  #
  # The AST is built by the various <tt>#build</tt> methods in the parse tree.
  #
  # The AST classes are defined in the Cucumber::Ast module.
  module Parser
    def self.load_parser(keywords)
      Loader.new(keywords)
    end
    
    class Loader
      def initialize(keywords)
        @keywords = keywords
        i18n_tt = File.expand_path(File.dirname(__FILE__) + '/parser/i18n.tt')
        template = File.open(i18n_tt, Cucumber.file_mode('r')).read
        erb = ERB.new(template)
        grammar = erb.result(binding)
        Treetop.load_from_string(grammar)
        require 'cucumber/parser/feature'
      end

      def keywords(key, raw=false)
        return @keywords[key] if raw
        values = @keywords[key].split('|')
        values.map{|value| "'#{value}'"}.join(" / ")
      end
    end
  end
end