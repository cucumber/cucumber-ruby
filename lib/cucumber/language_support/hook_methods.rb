module Cucumber
  module LanguageSupport
    module HookMethods
      def matches_tag_names?(other_tag_names)
        tag_names.empty? || (tag_names.map{|tag| Ast::Tags.strip_prefix(tag)} & other_tag_names).any?
      end
    end
  end
end