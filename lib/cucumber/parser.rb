require 'treetop'
require 'cucumber/ast'
require 'cucumber/parser/file_parser'
require 'cucumber/parser/treetop_ext'
%w{basic table feature}.each{ |grammar| Treetop.load File.dirname(__FILE__) + "/parser/#{grammar}.tt" }

module Cucumber
  # Classes in this module parse feature files and translate the parse tree 
  # (concrete syntax tree) into an abstract syntax tree (AST) using
  # <a href="http://martinfowler.com/dslwip/EmbeddedTranslation.html">Embedded translation</a>.
  #
  # The AST is built by the various <tt>#build</tt> methods in the parse tree.
  #
  # The AST classes are defined in the Cucumber::Ast module.
  module Parser
  end
end