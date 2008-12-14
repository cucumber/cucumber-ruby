require 'cucumber/ast'
require 'cucumber/parser/file_parser'
require 'cucumber/parser/basic'
require 'cucumber/parser/table'
require 'cucumber/parser/feature'

module Cucumber
  # Classes in this module parse feature files and translate the parse tree 
  # (concrete syntax tree) into an abstract syntax tree (AST) using
  # <a href="http://martinfowler.com/dslwip/EmbeddedTranslation.html">Embedded translation</a>. 
  # The AST classes are defined in the Cucumber::Ast module.
  module Parser
  end
end