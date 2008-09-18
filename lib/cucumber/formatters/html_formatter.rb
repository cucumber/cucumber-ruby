module Cucumber
  module Formatters
    class HtmlFormatter
      def initialize(io, step_mother)
        @io = io
        @step_mother = step_mother
        @errors = []
      end

      def visit_features(features)
        # IMPORTANT NOTICE ABOUT JQUERY BELOW. THE ORIGINAL BACKSLASHES (\) HAVE
        # BEEN REPLACED BY DOUBLE BACKSLASHES (\\) IN THIS FILE TO MAKE SURE THEY
        # ARE PRINTED PROPERLY WITH ONLY ONE BACKSLASH (\).
        @io.puts(<<-HTML)
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html 
  PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <title>#{Cucumber.language['feature']}</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="Expires" content="-1" />
    <meta http-equiv="Pragma" content="no-cache" />
    <script type="text/javascript">
#{IO.read(File.dirname(__FILE__) + '/jquery.js')}
#{IO.read(File.dirname(__FILE__) + '/cucumber.js')}
    </script>
    <style>
#{IO.read(File.dirname(__FILE__) + '/cucumber.css')}
    </style>
  </head>
  <body>
    <div id="container">
HTML
        features.accept(self)
        @io.puts %{    </div>}
      end

      def visit_feature(feature)
        @io.puts %{      <dl class="feature new">}
        feature.accept(self)
        @io.puts %{        </dd>}
        @io.puts %{      </dl>}
      end
      
      def visit_header(header)
        header = header.gsub(/\n/, "<br />\n")
        @io.puts %{        <dt>#{header}}
        @io.puts %{        </dt>}
        @io.puts %{        <dd>}
      end

      def visit_regular_scenario(scenario)
        @io.puts %{          <dl class="new">}
        @io.puts %{            <dt>#{Cucumber.language['scenario']}: #{scenario.name}</dt>}
        @io.puts %{            <dd>}
        @io.puts %{              <ul>}
        scenario.accept(self)
        @io.puts %{              </ul>}
        @io.puts %{            </dd>}
        @io.puts %{          </dl>}
      end

      def visit_row_scenario(scenario)
        @io.puts %{          <dl class="new">}
        @io.puts %{            <dt>#{Cucumber.language['scenario']}: #{scenario.name}</dt>}
        @io.puts %{            <dd>}
        @io.puts %{              <table>}
        @io.puts %{                <thead>}
        @io.puts %{                  <tr>}
        @io.puts %{                    <th>COL 1</th>}
        @io.puts %{                    <th>COL 2</th>}
        @io.puts %{                  </tr>}
        @io.puts %{                </thead>}
        @io.puts %{                <tbody>}
        scenario.accept(self)
        @io.puts %{                </tbody>}
        @io.puts %{              </table>}
        @io.puts %{            </dd>}
        @io.puts %{          </dl>}
      end

      def visit_row_step(step)
        _, args, _ = step.regexp_args_proc(@step_mother)
        args.each do |arg|
          @io.puts %{                    <td id="#{step.id}"><span>#{arg}</span></td>}
        end
      end

      def visit_regular_step(step)
        regexp, _, _ = step.regexp_args_proc(@step_mother)
        @io.puts %{                <li class="new" id="#{step.id}">#{step.keyword} #{step.format(regexp, '<span>%s</span>')}</li>}
      end
      
      def step_passed(step, regexp, args)
        print_javascript_tag("stepPassed(#{step.id})")
      end
      
      def step_failed(step, regexp, args)
        @errors << step.error
        print_javascript_tag("stepFailed(#{step.id}, (<r><![CDATA[#{step.error.message}]]></r>).toString(), (<r><![CDATA[#{step.error.backtrace.join("\n")}]]></r>).toString())")
      end
      
      def step_pending(step, regexp, args)
        print_javascript_tag("stepPending(#{step.id})")
      end
      
      def step_skipped(step)
        # noop
      end

      def print_javascript_tag(js)
        @io.puts %{    <script type="text/javascript">#{js}</script>}
      end

      def dump
        @io.puts <<-HTML
  </body>
</html>
HTML
      end
    end
  end
end
