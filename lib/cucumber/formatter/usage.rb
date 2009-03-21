require 'cucumber/formatter/progress'

module Cucumber
  module Formatter
    class Usage < Ast::Visitor
      include Console

      def initialize(step_mother, io, options)
        super(step_mother)
        @io = io
        @options = options
        @step_definitions = Hash.new { |h,step_definition| h[step_definition] = [] }
        @locations = []
      end

      def visit_features(features)
        super
        print_summary
      end

      def visit_step(step)
        @step = step
        super
      end

      def visit_step_name(keyword, step_match, status, source_indent, background)
        if step_match.step_definition
          location = @step.file_colon_line
          return if @locations.index(location)
          @locations << location
          
          description = format_step(keyword, step_match, status, nil)
          length = (keyword + step_match.format_args).jlength
          @step_definitions[step_match.step_definition] << [step_match, description, length, location]
        end
      end

      def print_summary
        sorted_defs = @step_definitions.keys.sort_by{|step_definition| step_definition.backtrace_line}
        
        sorted_defs.each do |step_definition|          
          step_matches_and_descriptions = @step_definitions[step_definition].sort_by do |step_match_and_description|
            step_match = step_match_and_description[0]
            step_match.step_definition.regexp.inspect
          end

          step_matches = step_matches_and_descriptions.map{|step_match_and_description| step_match_and_description[0]}

          lengths = step_matches_and_descriptions.map do |step_match_and_description| 
            step_match_and_description[2]
          end
          lengths << step_definition.text_length
          max_length = lengths.max

          @io.print step_definition.regexp.inspect
          @io.puts format_string("   # #{step_definition.file_colon_line}".indent(max_length - step_definition.text_length), :comment)
          step_matches_and_descriptions.each do |step_match_and_description|
            step_match      = step_match_and_description[0]
            description     = step_match_and_description[1]
            length          = step_match_and_description[2]
            file_colon_line = step_match_and_description[3]
            @io.print " #{description}"
            @io.puts format_string(" # #{file_colon_line}".indent(max_length - length), :comment)
          end
        end
      end
    end
  end
end
