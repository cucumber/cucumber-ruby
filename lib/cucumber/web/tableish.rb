require 'nokogiri'

module Cucumber
  module Tableish
    # http://reference.sitepoint.com/css/understandingnthchildexpressions
    def tableish(options)
      _tableish(response_body, options)
    end

    def _tableish(html, options)
      doc = Nokogiri::HTML(html)
      parent = doc.css(options[:parent])[0]
      parent.css(options[:row]) do |row|
        row.map do |element|
          element
        end
      end
    end
  end
end
