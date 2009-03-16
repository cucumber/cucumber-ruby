module Tag
  # Custom formatter that reports occurrences of each tag
  class Count < Cucumber::Ast::Visitor
    def initialize(step_mother, io, options)
      super(step_mother)
      @io = io
      @counts = Hash.new{|h,k| h[k] = 0}
    end

    def visit_features(features)
      super
      print_summary
    end

    def visit_tag_name(tag_name)
      @counts[tag_name] += 1
    end
    
    def print_summary
      matrix = @counts.to_a.sort{|paira, pairb| paira[0] <=> pairb[0]}.transpose
      table = Cucumber::Ast::Table.new(matrix)
      Cucumber::Formatter::Pretty.new(@step_mother, @io, {}).visit_multiline_arg(table)
    end
  end
end