require 'cucumber/formatter/console'
require 'fileutils'
require 'prawn'
require "prawn/layout"
require "prawn/format"

module Cucumber
  module Formatter

    BLACK = '000000'
    GREY = '999999'

    class Pdf < Ast::Visitor
      include FileUtils
      include Console
      attr_writer :indent

      def initialize(step_mother, io, options)
        super(step_mother)
        raise "You *must* specify --out FILE for the pdf formatter" unless File === io

        if(options[:dry_run])
          @status_colors = { :passed => BLACK, :skipped => BLACK, :undefined => BLACK, :failed => BLACK}
        else
          @status_colors = { :passed => '055902', :skipped => GREY, :undefined => 'F27405', :failed => '730202'}
        end

        @pdf = Prawn::Document.new
        @scrap = Prawn::Document.new
        @doc = @scrap
        @io = io
        @options = options
        @exceptions = []
        @indent = 0
        @buffer = []
        puts "writing to #{io.path}"
        begin
          @pdf.image open("features/support/logo.png"), :position => :center, :width => 500
        rescue
        end
        @pdf.text "\n\n\nCucumber features", :align => :center, :size => 32
        @pdf.text "Generated: #{Time.now.strftime("%Y-%m-%d %H:%M")}", :size => 10, :at => [0, 24]
        @pdf.text "Command: <code>cucumber #{ARGV.join(" ")}</code>", :size => 10, :at => [0,10]
        unless options[:dry_run]
          @pdf.bounding_box [450,100] , :width => 100 do  
            @pdf.text 'Legend', :size => 10
            @status_colors.each do |k,v|
              @pdf.fill_color v
              @pdf.text k.to_s, :size => 10
              @pdf.fill_color BLACK
            end
          end
        end
      end

      def keep_with(&block)
        @buffer << block
      end

      def render(doc)
        @doc = doc
        @buffer.each do |proc|
          proc.call
        end
      end

      # This method does a 'test' rendering on a blank page, to see the rendered height of the buffer
      # if that too high for the space left on the age in the real document, we do a page break.
      # This obviously doesn't work if a scenario is longer than a whole page (God forbid)
      def flush
        @scrap.start_new_page
        oldy = @scrap.y
        render @scrap
        height = (oldy - @scrap.y) + 36 # whops magic number
        if ((@pdf.y - height) < @pdf.bounds.bottom)
          @pdf.start_new_page
        end
        render @pdf
        @pdf.move_down(20)
        @buffer = []
      end

      # regular visitor entries
      def visit_features(features)
        super
        @pdf.render_file(@io.path)
        puts "\ndone"
      end

      def visit_feature_name(name)
        @pdf.start_new_page
        name["Feature:"] = "" if name["Feature:"]
        names = name.split("\n")
        @pdf.fill_color GREY
        @pdf.text('Feature', :align => :center)
        @pdf.fill_color BLACK
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

      def visit_feature_element(feature_element)
        record_tag_occurrences(feature_element, @options)
        super
        flush
      end

      def visit_feature(feature)
        super
        flush
      end

      def visit_feature_element_name(keyword, name)
        names = name.empty? ? [name] : name.split("\n")
        print "."
        STDOUT.flush

        keep_with do
          @doc.move_down(20)
          @doc.fill_color GREY
          @doc.text("#{keyword}", :size => 8)
          @doc.fill_color BLACK
          @doc.text("#{names[0]}", :size => 16)
          names[1..-1].each { |s| @doc.text(s, :size => 12) }
          @doc.text("\n")
        end
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

      def colorize(text, status)
        keep_with do
          @doc.fill_color(@status_colors[status] || BLACK)
          @doc.text(text)
          @doc.fill_color(BLACK)
        end
      end

      def visit_step_name(keyword, step_match, status, source_indent, background)
        line = "<b>#{keyword}</b> #{step_match.format_args("%s").gsub('<', '&lt;').gsub('>', '&gt;')}"
        colorize(line, status)
      end

      def visit_background(background)
        @in_background = true
        super
        @in_background = nil
      end

      def visit_multiline_arg(table)
        if(table.kind_of? Cucumber::Ast::Table)
          keep_with do
            @doc.table(table.rows << table.headers , :position => :center, :row_colors => ['ffffff', 'f0f0f0'])
          end
        end
        super
      end

      #using row_color hack to highlight each row correctly
      def visit_outline_table(table)
        row_colors = table.example_rows.map { |r| @status_colors[r.status] unless r.status == :skipped}
        keep_with do
          @doc.table(table.rows, :headers => table.headers, :position => :center, :row_colors => row_colors)
        end
      end

      def visit_py_string(string)
        s = %{"""\n#{string}\n"""}.indent(10)
        s = s.split("\n").map{|l| l =~ /^\s+$/ ? '' : l}
        s.each do |line|
          line.gsub!('<', '&lt;')
          line.gsub!('>', '&gt;')
          keep_with { @doc.text line, :size => 8 }
        end
      end

      def visit_comment(comment)
        comment.accept(self)
      end

      def visit_comment_line(comment_line)
      end

      def visit_tag_name(tag_name)
        tag = format_string("@#{tag_name}", :tag).indent(@indent)
        # TODO should we render tags at all? skipped for now. difficult to place due to page breaks
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
    end
  end
end
