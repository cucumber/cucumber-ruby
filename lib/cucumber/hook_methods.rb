module Cucumber
  module HookMethods
    def matches_tag_names?(other_tag_names)
      tag_names.empty? || (tag_names & other_tag_names).any?
    end
  end
end