require 'cucumber/formatter/console'
require 'fileutils'
require 'prawn'
require "prawn/layout"
require "prawn/format"

module Cucumber
  module Formatter

    class Pdf < Ast::Visitor
      include FileUtils
      include Console
      attr_writer :indent

      def initialize(step_mother, io, options)
        puts "no file! please specify --pdf FILENAME" and exit if options[:outfile].blank?

        super(step_mother)
        @pdf = Prawn::Document.new
        @scrap = Prawn::Document.new
        @io = io
        @options = options
        @exceptions = []
        @indent = 0
        @prefixes = options[:prefixes] || {}
        @buffer = []
        @rowbuffer = []
        begin
          @pdf.image open("features/support/logo.png"), :position => :center, :width => 500
        rescue
        end
        @pdf.text "\n\n\nCucumber features", :align => :center, :size => 32
        @pdf.text "Generated: #{Time.now.strftime("%Y-%m-%d %H:%M")}", :size => 10, :at => [0, 24]
        @pdf.text "Command: <code>cucumber #{ARGV.join(" ")}</code>", :size => 10, :at => [0,10]
      end

      def visit_features(features)
        super
        @pdf.render_file(options[:outfile])
        @io.puts "\ndone"
      end

      def visit_feature_element(feature_element)
        record_tag_occurrences(feature_element, @options)
        super 
        flush_buffer
      end

      def visit_feature(feature)
        super  
        flush_buffer
      end

      def visit_comment(comment)
        comment.accept(self)
      end

      def visit_comment_line(comment_line)
        #@io.puts(comment_line.indent(@indent))
        #@io.flush
      end

      def visit_tag_name(tag_name)
        tag = format_string("@#{tag_name}", :tag).indent(@indent)
        # TODO should we render tags at all?
      end

      def visit_feature_name(name)
        @pdf.start_new_page
        name["Feature:"] = "" if name["Feature:"]
        names = name.split("\n")
        @pdf.fill_color '999999'
        @pdf.text('Feature', :align => :center)
        @pdf.fill_color '000000'
        names.each_with_index do |nameline, i|
          case i
          when 0
            @pdf.text(nameline.strip, :size => 30, :align => :center )
            @pdf.text("\n")
          else
            @pdf.text(nameline.strip, :size => 12)
          end
        end
        @pdf.move_down(30)
      end

      def visit_background_name(keyword, name, file_colon_line, source_indent)
        visit_feature_element_name(keyword, name)
      end

      def visit_examples_name(keyword, name)
        visit_feature_element_name(keyword, name)
        
      end

      def visit_scenario_name(keyword, name, file_colon_line, source_indent)
        visit_feature_element_name(keyword, name)
      end

      def render_buffer(doc)
        @buffer.each do |lineinfo|
          object, o = lineinfo
          options = { :plain => true }
          options.merge! o if o 
          if object.kind_of? Hash   #this is an example table 
            doc.table(object[:tabledata], :headers => object[:headers])
            @rowbuffer = []
          else(options)
            @pdf.fill_color options[:color] if options[:color]
            doc.text(object, options)
            @pdf.fill_color '000000'
          end
        end
      end

      def flush_buffer
        @scrap.start_new_page
        oldy = @scrap.y
        render_buffer @scrap
        height = (oldy - @scrap.y) + 36 #TODO remember page breaks in long entries, this is probably a bug
        #@pdf.text("PAGEBREAK (rows: #{@buffer.size}, box height: #{height}, y was #{@pdf.y}, bottom: #{@pdf.bounds.bottom} )")
        if ((@pdf.y - height) < @pdf.bounds.bottom)
          @pdf.start_new_page
        end
        render_buffer @pdf

        @pdf.move_down(20)
        @buffer = []
      end

      def visit_feature_element_name(keyword, name)
        names = name.empty? ? [name] : name.split("\n")
        @io.print "."
        @io.flush
        @buffer << ["#{keyword}" , { :size => 10, :color => "999999" } ]
        @buffer << ["#{names[0]}", { :size => 16 } ]
        @buffer << "\n"
        names[1..-1].each {|s| @buffer << [s, { :size => 12 }] }
      end

      def visit_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        if exception
          return if @exceptions.index(exception)
          @exceptions << exception
        end
        return if status != :failed && @in_background ^ background
        @status = status
        super
      end

      def visit_step_name(keyword, step_match, status, source_indent, background)
        source_indent = nil unless @options[:source]
        line = format_step(keyword, step_match, status, source_indent)
        line.gsub!('<', '&lt;')
        line.gsub!('>', '&gt;')
        %w(Given When Then).each do |keyword|
          line.gsub!(keyword, "<b>#{keyword}</b>")
        end
        @buffer << [line, { :plain => false }]
      end

      #TODO handle this?
      def visit_multiline_arg(multiline_arg)
        return if @options[:no_multiline]
        @table = multiline_arg
        super
      end

      def visit_background(background)
        @in_background = true
        super
        @in_background = nil
      end

      def visit_table_row(table_row)        
        @buffer << { :tabledata => [], :headers => [] }  unless @buffer[-1].is_a? Hash
        headers = @buffer[-1][:headers]
        super
        if(headers.empty?)    
          @buffer[-1][:headers] = @rowbuffer unless @rowbuffer.empty?
        else
          @buffer[-1][:tabledata] << @rowbuffer unless @rowbuffer.empty?
        end
        @rowbuffer = []
      end

      def visit_py_string(string)
        s = %{"""\n#{string}\n"""}.indent(10)
        s = s.split("\n").map{|l| l =~ /^\s+$/ ? '' : l}
        s.each do |line|
          line.gsub!('<', '&lt;')
          line.gsub!('>', '&gt;')
          @buffer << [line, { :size => 8 }]
        end
      end

      def visit_table_cell_value(value, status)  
        @rowbuffer << value.to_s || ' '
      end
    end
  end
end
