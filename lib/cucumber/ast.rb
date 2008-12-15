require 'cucumber/ast/feature'
require 'cucumber/ast/scenario'
require 'cucumber/ast/tags'
require 'cucumber/ast/comment'
require 'cucumber/ast/table'

module Cucumber
  # Classes in this module represent the Abstract Syntax Tree (AST)
  # that gets created when feature files are parsed.
  #
  # The AST can be traversed with a visitor, which must define the
  # following methods:
  #
  #   class SomeVisitor
  #     def visit_feature
  #     end
  #   end
  module Ast
  end
end