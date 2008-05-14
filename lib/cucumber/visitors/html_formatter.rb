module Cucumber
  module Visitors
    class HtmlFormatter
      def initialize(io)
        @io = io
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
    <link href="style.css" rel="stylesheet" type="text/css" />
  </head>
  <body>
    <div id="container">
HTML
        stories.accept(self)
        @io.puts(<<-HTML)
    </div>
  </body>
</head>
HTML
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
        @io.puts "                <li class=\"new\">#{step.name}</li>"
      end
      
      def dump
      end
    end
  end
end
