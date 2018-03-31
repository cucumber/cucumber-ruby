# frozen_string_literal: true

require 'erb'
require 'cucumber/formatter/duration'
require 'cucumber/formatter/io'
require 'cucumber/formatter/html_builder'
require 'pathname'

module Cucumber
  module Formatter
    class Html
      # TODO: remove coupling to types
      AST_CLASSES = {
        Cucumber::Core::Ast::Scenario        => 'scenario',
        Cucumber::Core::Ast::ScenarioOutline => 'scenario outline'
      }

      AST_DATA_TABLE = LegacyApi::Ast::MultilineArg::DataTable

      include ERB::Util # for the #h method
      include Duration
      include Io

      attr_reader :builder
      private :builder

      def initialize(runtime, path_or_io, options)
        @io = ensure_io(path_or_io)
        @runtime = runtime
        @options = options
        @buffer = {}
        @builder = HtmlBuilder.new(target: @io, indent: 0)
        @feature_number = 0
        @scenario_number = 0
        @step_number = 0
        @header_red = nil
        @delayed_messages = []
        @inside_outline        = false
        @previous_step_keyword = nil
      end

      def embed(src, mime_type, label)
        if image?(mime_type)
          src = src_is_file_or_data?(src) ? src : "data:#{standardize_mime_type(mime_type)},#{src}"
          builder.embed(type: :image, src: path(src), label: label, id: next_id(:img))
        else
          builder.embed(type: :text, src: src, label: label, id: next_id(:text))
        end
      end

      def path(src)
        if @io.respond_to?(:path) && File.file?(src)
          out_dir = Pathname.new(File.dirname(File.absolute_path(@io.path)))
          src = Pathname.new(File.absolute_path(src)).relative_path_from(out_dir)
        end

        src
      end

      def standardize_mime_type(mime_type)
        mime_type =~ /;base[0-9]+$/ ? mime_type : mime_type + ';base64'
      end

      def src_is_file_or_data?(src)
        File.file?(src) || src =~ /^data:image\/(png|gif|jpg|jpeg);base64,/
      end

      def image?(mime_type)
        mime_type =~ /^image\/(png|gif|jpg|jpeg)/
      end

      def before_features(features)
        @step_count = features && features.step_count || 0 # TODO: Make this work with core!

        builder.build_document!
        builder.format_features! features
      end

      def after_features(features)
        print_stats(features)
        builder << '</div>'
        builder << '</body>'
        builder << '</html>'
      end

      def before_feature(_feature)
        @exceptions = []
        builder << '<div class="feature">'
      end

      def after_feature(_feature)
        builder << '</div>'
      end

      def before_comment(_comment)
        builder << '<pre class="comment">'
      end

      def after_comment(_comment)
        builder << '</pre>'
      end

      def comment_line(comment_line)
        builder.text!(comment_line)
        builder.br
      end

      def after_tags(_tags)
        @tag_spacer = nil
      end

      def tag_name(tag_name)
        builder.text!(@tag_spacer) if @tag_spacer
        @tag_spacer = ' '
        builder.span(tag_name, :class => 'tag')
      end

      def feature_name(keyword, name)
        lines = name.split(/\r?\n/)
        return if lines.empty?
        builder.h2 do |h2|
          builder.span(keyword + ': ' + lines[0], :class => 'val')
        end
        builder.p(:class => 'narrative') do
          lines[1..-1].each do |line|
            builder.text!(line.strip)
            builder.br
          end
        end
      end

      def before_test_case(_test_case)
        @previous_step_keyword = nil
      end

      def before_background(_background)
        @in_background = true
        builder << '<div class="background">'
      end

      def after_background(_background)
        @in_background = nil
        builder << '</div>'
      end

      def background_name(keyword, name, _file_colon_line, _source_indent)
        @listing_background = true
        builder.h3(:id => "background_#{@scenario_number}") do |h3|
          builder.span(keyword, :class => 'keyword')
          builder.text!(' ')
          builder.span(name, :class => 'val')
        end
      end

      def before_feature_element(feature_element)
        @scenario_number += 1
        @scenario_red = false
        css_class = AST_CLASSES[feature_element.class]
        builder << "<div class='#{css_class}'>"
        @in_scenario_outline = feature_element.class == Cucumber::Core::Ast::ScenarioOutline
      end

      def after_feature_element(_feature_element)
        unless @in_scenario_outline
          print_messages
          builder << '</ol>'
        end
        builder << '</div>'
        @in_scenario_outline = nil
      end

      def scenario_name(keyword, name, file_colon_line, _source_indent)
        builder.span(:class => 'scenario_file') do
          builder << file_colon_line
        end
        @listing_background = false
        scenario_id = "scenario_#{@scenario_number}"
        if @inside_outline
          @outline_row += 1
          scenario_id += "_#{@outline_row}"
          @scenario_red = false
        end
        builder.h3(:id => scenario_id) do
          builder.span(keyword + ':', :class => 'keyword')
          builder.text!(' ')
          builder.span(name, :class => 'val')
        end
      end

      def before_outline_table(_outline_table)
        @inside_outline = true
        @outline_row = 0
        builder << '<table>'
      end

      def after_outline_table(_outline_table)
        builder << '</table>'
        @outline_row = nil
        @inside_outline = false
      end

      def before_examples(_examples)
        builder << '<div class="examples">'
      end

      def after_examples(_examples)
        builder << '</div>'
      end

      def examples_name(keyword, name)
        builder.h4 do
          builder.span(keyword, :class => 'keyword')
          builder.text!(' ')
          builder.span(name, :class => 'val')
        end
      end

      def before_steps(_steps)
        builder << '<ol>'
      end

      def after_steps(_steps)
        print_messages
        builder << '</ol>' if @in_background || @in_scenario_outline
      end

      def before_step(step)
        print_messages
        @step_id = step.dom_id
        @step_number += 1
        @step = step
      end

      def after_step(_step)
        move_progress
      end

      def before_step_result(_keyword, step_match, _multiline_arg, status, exception, _source_indent, background, _file_colon_line)
        @step_match = step_match
        @hide_this_step = false
        if exception
          if @exceptions.include?(exception)
            @hide_this_step = true
            return
          end
          @exceptions << exception
        end
        if status != :failed && @in_background ^ background
          @hide_this_step = true
          return
        end
        @status = status
        return if @hide_this_step
        scenario_color(status)
        builder << "<li id='#{@step_id}' class='step #{status}'>"
      end

      def after_step_result(keyword, step_match, _multiline_arg, status, _exception, _source_indent, _background, _file_colon_line)
        return if @hide_this_step
        # print snippet for undefined steps
        unless outline_step?(@step)
          keyword = @step.actual_keyword(@previous_step_keyword)
          @previous_step_keyword = keyword
        end
        if status == :undefined
          builder.pre do |pre|
            # TODO: snippet text should be an event sent to the formatter so we don't
            # have this couping to the runtime.
            pre << @runtime.snippet_text(keyword, step_match.instance_variable_get('@name') || '', @step.multiline_arg)
          end
        end
        builder << '</li>'
        print_messages
      end

      def step_name(keyword, step_match, status, _source_indent, background, _file_colon_line)
        background_in_scenario = background && !@listing_background
        @skip_step = background_in_scenario

        unless @skip_step
          build_step(keyword, step_match, status)
        end
      end

      def exception(exception, _status)
        return if @hide_this_step
        print_messages
        build_exception_detail(exception)
      end

      def extra_failure_content(file_colon_line)
        @snippet_extractor ||= SnippetExtractor.new
        "<pre class=\"ruby\"><code>#{@snippet_extractor.snippet(file_colon_line)}</code></pre>"
      end

      def before_multiline_arg(multiline_arg)
        return if @hide_this_step || @skip_step
        if AST_DATA_TABLE === multiline_arg
          builder << '<table>'
        end
      end

      def after_multiline_arg(multiline_arg)
        return if @hide_this_step || @skip_step
        if AST_DATA_TABLE === multiline_arg
          builder << '</table>'
        end
      end

      def doc_string(string)
        return if @hide_this_step
        builder.pre(:class => 'val') do |pre|
          builder << h(string).gsub("\n", '&#x000A;')
        end
      end

      def before_table_row(table_row)
        @row_id = table_row.dom_id
        @col_index = 0
        return if @hide_this_step
        builder << "<tr class='step' id='#{@row_id}'>"
      end

      def after_table_row(table_row)
        return if @hide_this_step
        print_table_row_messages
        builder << '</tr>'
        if table_row.exception
          builder.tr do
            builder.td(:colspan => @col_index.to_s, :class => 'failed') do
              builder.pre do |pre|
                pre << h(format_exception(table_row.exception))
              end
            end
          end
          if table_row.exception.is_a? ::Cucumber::Pending
            set_scenario_color_pending
          else
            set_scenario_color_failed
          end
        end
        if @outline_row
          @outline_row += 1
        end
        @step_number += 1
        move_progress
      end

      def table_cell_value(value, status)
        return if @hide_this_step

        @cell_type = @outline_row == 0 ? :th : :td
        attributes = {:id => "#{@row_id}_#{@col_index}", :class => 'step'}
        attributes[:class] += " #{status}" if status
        build_cell(@cell_type, value, attributes)
        scenario_color(status) if @inside_outline
        @col_index += 1
      end

      def puts(message)
        @delayed_messages << message
      end

      def print_messages
        return if @delayed_messages.empty?

        @delayed_messages.each do |ann|
          builder.li(:class => 'step message') do
            builder << ann
          end
        end
        empty_messages
      end

      def print_table_row_messages
        return if @delayed_messages.empty?

        builder.td(:class => 'message') do
          builder << @delayed_messages.join(', ')
        end
        empty_messages
      end

      def empty_messages
        @delayed_messages = []
      end

      def after_test_case(_test_case, result)
        if result.failed? && !@scenario_red
          set_scenario_color_failed
        end
      end

      protected

      def next_id(type)
        @indices ||= Hash.new { 0 }
        @indices[type] += 1
        "#{type}_#{@indices[type]}"
      end

      def build_exception_detail(exception)
        backtrace = Array.new

        builder.div(:class => 'message') do
          message = exception.message

          if defined?(RAILS_ROOT) && message.include?('Exception caught')
            matches = message.match(/Showing <i>(.+)<\/i>(?:.+) #(\d+)/)
            backtrace += ["#{RAILS_ROOT}/#{matches[1]}:#{matches[2]}"] if matches
            matches = message.match(/<code>([^(\/)]+)<\//m)
            message = matches ? matches[1] : ''
          end

          unless exception.instance_of?(RuntimeError)
            message = "#{message} (#{exception.class})"
          end

          builder.pre do
            builder.text!(message)
          end
        end

        builder.div(:class => 'backtrace') do
          builder.pre do
            backtrace = exception.backtrace
            backtrace.delete_if { |x| x =~ /\/gems\/(cucumber|rspec)/ }
            builder << backtrace_line(backtrace.join("\n"))
          end
        end

        extra = extra_failure_content(backtrace)
        builder << extra unless extra == ''
      end

      def scenario_color(status)
        if status.nil? || status == :undefined || status == :pending
          set_scenario_color_pending
        end
        if status == :failed
          set_scenario_color_failed
        end
      end

      def set_scenario_color_failed
        builder.script do
          builder.text!("makeRed('cucumber-header');") unless @header_red
          @header_red = true
          scenario_or_background = @in_background ? 'background' : 'scenario'
          builder.text!("makeRed('#{scenario_or_background}_#{@scenario_number}');") unless @scenario_red
          @scenario_red = true
          if @options[:expand] && @inside_outline
            builder.text!("makeRed('#{scenario_or_background}_#{@scenario_number}_#{@outline_row}');")
          end
        end
      end

      def set_scenario_color_pending
        builder.script do
          builder.text!("makeYellow('cucumber-header');") unless @header_red
          scenario_or_background = @in_background ? 'background' : 'scenario'
          builder.text!("makeYellow('#{scenario_or_background}_#{@scenario_number}');") unless @scenario_red
        end
      end

      def build_step(keyword, step_match, _status)
        step_name = step_match.format_args(lambda {|param| %{<span class="param">#{param}</span>}})
        builder.div(:class => 'step_name') do |div|
          builder.span(keyword, :class => 'keyword')
          builder.span(:class => 'step val') do |name|
            name << h(step_name).gsub(/&lt;span class=&quot;(.*?)&quot;&gt;/, '<span class="\1">').gsub(/&lt;\/span&gt;/, '</span>')
          end
        end

        step_file = step_match.file_colon_line
        step_file.gsub(/^([^:]*\.rb):(\d*)/) do
          if ENV['TM_PROJECT_DIRECTORY']
            step_file = "<a href=\"txmt://open?url=file://#{File.expand_path($1)}&line=#{$2}\">#{$1}:#{$2}</a> "
          end
        end

        builder.div(:class => 'step_file') do |div|
          builder.span do
            builder << step_file
          end
        end
      end

      def build_cell(cell_type, value, attributes)
        builder.__send__(cell_type, attributes) do
          builder.div do
            builder.span(value, :class => 'step param')
          end
        end
      end

      def move_progress
        builder << " <script type=\"text/javascript\">moveProgressBar('#{percent_done}');</script>"
      end

      def percent_done
        result = 100.0
        if @step_count != 0
          result = ((@step_number).to_f / @step_count.to_f * 1000).to_i / 10.0
        end
        result
      end

      def format_exception(exception)
        ([exception.message.to_s] + exception.backtrace).join("\n")
      end

      def backtrace_line(line)
        if ENV['TM_PROJECT_DIRECTORY']
          line.gsub(/^([^:]*\.(?:rb|feature|haml)):(\d*).*$/) do
            "<a href=\"txmt://open?url=file://#{File.expand_path($1)}&line=#{$2}\">#{$1}:#{$2}</a> "
          end
        else
          line
        end
      end

      def print_stats(features)
        builder <<  "<script type=\"text/javascript\">document.getElementById('duration').innerHTML = \"Finished in <strong>#{format_duration(features.duration)} seconds</strong>\";</script>"
        builder <<  "<script type=\"text/javascript\">document.getElementById('totals').innerHTML = \"#{print_stat_string(features)}\";</script>"
      end

      def print_stat_string(_features)
        string = String.new
        string << dump_count(@runtime.scenarios.length, 'scenario')
        scenario_count = print_status_counts {|status| @runtime.scenarios(status)}
        string << scenario_count if scenario_count
        string << '<br />'
        string << dump_count(@runtime.steps.length, 'step')
        step_count = print_status_counts {|status| @runtime.steps(status)}
        string << step_count if step_count
      end

      def print_status_counts
        counts = [:failed, :skipped, :undefined, :pending, :passed].map do |status|
          elements = yield status
          elements.any? ? "#{elements.length} #{status}" : nil
        end.compact
        return " (#{counts.join(', ')})" if counts.any?
      end

      def dump_count(count, what, state = nil)
        [count, state, "#{what}#{count == 1 ? '' : 's'}"].compact.join(' ')
      end

      def outline_step?(_step)
        not @step.step.respond_to?(:actual_keyword)
      end

      class SnippetExtractor #:nodoc:
        class NullConverter; def convert(code, _pre); code; end; end #:nodoc:

        begin
          require 'syntax/convertors/html'
          @@converter = Syntax::Convertors::HTML.for_syntax 'ruby'
        rescue LoadError
          @@converter = NullConverter.new
        end

        def snippet(error)
          raw_code, line = snippet_for(error[0])
          highlighted = @@converter.convert(raw_code, false)
          highlighted += "\n<span class=\"comment\"># gem install syntax to get syntax highlighting</span>" if @@converter.is_a?(NullConverter)
          post_process(highlighted, line)
        end

        def snippet_for(error_line)
          if error_line =~ /(.*):(\d+)/
            file = $1
            line = $2.to_i
            [lines_around(file, line), line]
          else
            ["# Couldn't get snippet for #{error_line}", 1]
          end
        end

        def lines_around(file, line)
          if File.file?(file)
            begin
              lines = File.open(file).read.split("\n")
            rescue ArgumentError
              return "# Couldn't get snippet for #{file}"
            end
            min = [0, line - 3].max
            max = [line + 1, lines.length - 1].min
            selected_lines = []
            selected_lines.join("\n")
            lines[min..max].join("\n")
          else
            "# Couldn't get snippet for #{file}"
          end
        end

        def post_process(highlighted, offending_line)
          new_lines = []
          highlighted.split("\n").each_with_index do |line, i|
            new_line = "<span class=\"linenum\">#{offending_line + i - 2}</span>#{line}"
            new_line = "<span class=\"offending\">#{new_line}</span>" if i == 2
            new_lines << new_line
          end
          new_lines.join("\n")
        end
      end
    end
  end
end
