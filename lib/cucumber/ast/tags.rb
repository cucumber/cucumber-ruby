require 'set'

module Cucumber
  module Ast

    # Holds the names of tags parsed from a feature file:
    #
    #   @invoice @release_2
    #
    # This gets stored internally as <tt>["invoice", "release_2"]</tt>
    #
    class Tags #:nodoc:

      class And #:nodoc:
        def initialize(tag_names)
          @negative_tags, @positive_tags = tag_names.partition{|tag_name| Tags.exclude_tag?(tag_name)}
          @negative_tags = Tags.strip_negative_char(@negative_tags)
        end

        def matches?(tag_names)
          included?(tag_names) && !excluded?(tag_names)
        end

        private

        def excluded?(tag_names)
          (@negative_tags & tag_names).any?
        end

        def included?(tag_names)
          positive_tag_set = Set.new(@positive_tags)
          tag_names_set = Set.new(tag_names)
          positive_tag_set.subset?(tag_names_set)
        end
      end

      class Or #:nodoc:
        def initialize(tag_exp)
          @exp = tag_exp
        end

        def matches?(tag_names)
          @exp.inject(false){|matches, tag_exp| matches || tag_exp.matches?(tag_names)}
        end
      end

      class << self
        EXCLUDE_PATTERN = /^~/

        def matches?(source_tag_names, tag_names)
          validate_tags(tag_names)
          tag_names.empty? ? true : check_if_tags_match(source_tag_names, tag_names)
        end

        def exclude_tag?(tag_name)
          tag_name =~ EXCLUDE_PATTERN
        end

        def strip_negative_char(tag_names)
          tag_names.map{|name| name[1..-1]}
        end

        private

        def validate_tags(tag_name_list)
          all_tag_names = tag_name_list.flatten
          exclude_tag_names, include_tag_names = all_tag_names.partition{|tag_name| exclude_tag?(tag_name)}
          exclude_tag_names = strip_negative_char(exclude_tag_names)
          check_at_sign_prefix(exclude_tag_names + include_tag_names)
        end

        def check_if_tags_match(source_tag_names, tag_names)
          tag_exp = Or.new(tag_names.map{|tag_name_list| And.new(tag_name_list) })
          tag_exp.matches?(source_tag_names)
        end

        def check_at_sign_prefix(tag_names)
          tag_names.each{|tag_name| raise "Tag names must start with an @ sign. The following tag name didn't: #{tag_name}" unless tag_name[0..0] == '@'}
        end

      end

      attr_reader :tag_names

      def initialize(line, tag_names)
        @line, @tag_names = line, tag_names
      end

      def accept(visitor)
        return if $cucumber_interrupted
        @tag_names.each do |tag_name|
          visitor.visit_tag_name(tag_name)
        end
      end

      def accept_hook?(hook)
        self.class.matches?(@tag_names, hook.tag_names)
      end

      def count(tag)
        # See discussion:
        # http://github.com/weplay/cucumber/commit/2dc592acdf3f7c1a0c333a8164649936bb82d983
        if @tag_names.respond_to?(:count) && @tag_names.method(:count).arity > 0
          @tag_names.count(tag) # 1.9
        else
          @tag_names.select{|t| t == tag}.length  # 1.8
        end
      end

      def to_sexp
        @tag_names.map{|tag_name| [:tag, tag_name]}
      end
    end
  end
end
