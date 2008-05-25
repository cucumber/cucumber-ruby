module Cucumber
  module Visitors
    class HtmlFormatter
      def initialize(io)
        @io = io
        @errors = []
      end

      def visit_stories(stories)
        @io.puts(<<-HTML)
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html 
  PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <title>Stories</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="Expires" content="-1" />
    <meta http-equiv="Pragma" content="no-cache" />
    <script type="text/javascript">
      function stepPassed(id) {
        var li = document.getElementById(id);
        li.className = 'passed';
      }

      function stepFailed(id) {
        var li = document.getElementById(id);
        li.className = 'failed';
      }

      function stepPending(id) {
        var li = document.getElementById(id);
        li.className = 'pending';
      }
    </script>
    <style>
body {
  background: #fff;
  font-size: 80%;
  margin:0pt;
  padding:0pt;
}

#container {
  background:white none repeat scroll 0%;
  font-family:Helvetica,Arial,sans-serif;
  margin:0pt auto;
  position:relative;
  text-align:left;
  top:1.0em;
  width:78em;
}

dl {
  font: normal 11px "Lucida Grande", Helvetica, sans-serif;
  margin-left: 5px;
}

dl.new {
  border-left: 5px solid #444444;
}

dl.pending {
  border-left: 5px solid #FAF834;
}

dl.failed {
  border-left: 5px solid #C20000;
}

dl.passed {
  border-left: 5px solid #65C400;
}

dt {
  color: #fff;
  padding: 3px;
  font-weight: bold;
}

dl.new > dt {
  background: #444444;
}

dl.pending > dt {
  color: #131313;
  background: #FAF834;
}

dl.failed > dt {
  background: #C20000;
}

dl.passed > dt {
  background: #65C400;
}

dd {
  margin: 0px 0px 0px 0px;
}

dd p, pre {
  padding: 5px;
  margin-top: 0;
  margin-bottom: 5px;
}

dl.passed > dd > p, li.passed {
  background: #DBFFB4; color: #3D7700;
  border-bottom: 1px solid #65C400;
}

dl.failed > dd > p, li.failed {
  color: #C20000; background: #FFFBD3;
  border-bottom: 1px solid #C20000;
}

dl.pending > dd > p, li.pending {
  color: #131313; background: #FCFB98;
  border-bottom: 1px solid #FAF834;
}

dl.new > dd > p, li.new {
  color: #444444; background: #DDDDDD;
  border-bottom: 1px solid #444444;
}

span.param, span.param_editor {
  font-weight: bold;
}

input {
  width: 100%;
}

ul {
  padding: 0px;
  list-style: none;
}

ul > li {
  margin: 5px 0px 5px 5px;
  padding: 3px 3px 3px 5px;
}

div.auto_complete ul {
  list-style-type: none;
  border: 2px solid #F0F0F0;
  margin: 0px;
  padding: 0px;
}

div.auto_complete ul li {
  background-color: white;
  list-style-type: none;
  display: block;
  margin: 0;
  padding: 2px;
}

div.auto_complete ul li.selected {
  color: #444444; background: #DDDDDD;
}
    </style>
  </head>
  <body>
    <div id="container">
HTML
        stories.accept(self)
        @io.puts "    </div>"
      end

      def visit_story(story)
        @io.puts "      <dl class=\"story new\">"
        story.accept(self)
        @io.puts "        </dd>"
        @io.puts "      </dl>"
      end
      
      def visit_header(header)
        @io.puts "        <dt>Story: #{header.name}</dt>"
      end

      def visit_narrative(narrative)
        @io.puts "        <dd>"
        @io.puts "          <p>"
        @io.puts narrative.text_value.gsub(/\n/, "<br />\n")
        @io.puts "          </p>"
      end

      def visit_scenario(scenario)
        @io.puts "          <dl class=\"new\">"
        @io.puts "            <dt>Scenario: #{scenario.name}</dt>"
        @io.puts "            <dd>"
        @io.puts "              <ul>"
        scenario.accept(self)
        @io.puts "              </ul>"
        @io.puts "            </dd>"
        @io.puts "          </dl>"
      end

      def visit_step(step)
        @io.puts "                <li class=\"new\" id=\"#{step.object_id}\">#{step.name}</li>"
      end
      
      def step_executed(step)
        js = case(step.error)
        when Pending
          "stepPending(#{step.object_id})"
        when NilClass
          "stepPassed(#{step.object_id})"
        else
          @errors << step.error
          "stepFailed(#{step.object_id})"
        end

        @io.puts "    <script type=\"text/javascript\">#{js}</script>"
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
