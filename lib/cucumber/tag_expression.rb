module Cucumber
  class TagExpression
    attr_reader :limits

    def self.parse(tag_expressions)
      tag_expressions.inject(TagExpression.new) { |e, expr| e.add(expr.strip.split(/\s*,\s*/)); e }
    end

    def initialize
      @ands = []
      @limits = {}
    end

    def add(tags)
      negatives, positives = tags.partition{|tag| tag =~ /^~/}
      positive_limits = Hash[*positives.map{|positive| tag, limit = positive.split(':'); [tag, limit ? limit.to_i : nil]}.flatten]
      @limits.merge!(positive_limits)
      @ands << (negatives + positive_limits.keys)
    end

    def eval(tags)
      return true if @ands.flatten.empty?
      vars = Hash[*tags.map{|tag| [tag, true]}.flatten]
      !!Kernel.eval(ruby_expression)
    end

  private

    def ruby_expression
      "(" + @ands.map do |ors|
        ors.map do |tag|
          if tag =~ /^~(.*)/
            "!vars['#{$1}']"
          else
            "vars['#{tag}']"
          end
        end.join("||")
      end.join(")&&(") + ")"
    end
  end
end
