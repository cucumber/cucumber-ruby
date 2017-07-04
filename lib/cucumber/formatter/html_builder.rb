# frozen_string_literal: true
require 'builder'
require 'pathname'

module Cucumber
  module Formatter
    class HtmlBuilder < Builder::XmlMarkup
      def embed_text(src: nil, label: nil, id: nil)
        raise ArgumentError, 'missing required argument' unless src && label && id # for Ruby 2.0 compatibility

        prepend_to_span('embed', %{<a id="#{id}" href="#{src}" title="#{label}">#{label}</a>})
      end

      def embed_image(src: nil, label: nil, id: nil)
        raise ArgumentError, 'missing required argument' unless src && label && id # for Ruby 2.0 compatibility

        prepend_to_span(
          'embed',
          %{<a href="" onclick="img=document.getElementById('#{id}'); img.style.display = (img.style.display == 'none' ? 'block' : 'none');return false">#{label}</a><br>&nbsp;
            <img id="#{id}" style="display: none" src="#{src}"/>}
        )
      end

      def declare!
        super(:DOCTYPE, :html, :PUBLIC, '-//W3C//DTD XHTML 1.0 Strict//EN', 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd')
      end

      def build_document!
        declare! # <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

        self << '<html xmlns ="http://www.w3.org/1999/xhtml">'

        set_head_tags
      end

      def format_features!(features)
        step_count = features && features.step_count || 0

        self << '<body>'
        self << "<!-- Step count #{step_count}-->"
        self << '<div class="cucumber">'

        div(id: 'cucumber-header') do
          div(id: 'label') do
            h1 'Cucumber Features'
          end

          summary_div
        end
      end

      private

      def summary_div
        div(id: 'summary') do
          p('', id: 'totals')
          p('', id: 'duration')

          expand_collapse
        end
      end

      def expand_collapse
        div(id: 'expand-collapse') do
          p('Expand All', id: 'expander')
          p('Collapse All', id: 'collapser')
        end
      end

      def prepend_to_span(span_class, content)
        span(class: span_class) do |pre|
          pre << content
        end
      end

      def inline_css
        style(type: 'text/css') do
          pn = ::Pathname.new(::File.dirname(__FILE__) + '/cucumber.css')
          self << pn.read
        end
      end

      def inline_js
        script(type: 'text/javascript') do
          self << inline_jquery
          self << inline_js_content
        end
      end

      def inline_jquery
        pn = ::Pathname.new(::File.dirname(__FILE__) + '/jquery-min.js')
        pn.read
      end

      def inline_js_content # rubocop:disable
        pn = ::Pathname.new(::File.dirname(__FILE__) + '/inline-js.js')
        pn.read
      end

      def set_head_tags
        head do
          meta('http-equiv' => 'Content-Type', :content => 'text/html;charset=utf-8')
          title 'Cucumber'
          inline_css
          inline_js
        end
      end
    end
  end
end