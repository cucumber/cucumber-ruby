require 'nokogiri'

module Cucumber
  module Tableish
    def tableish(row_selector, column_selectors)
      _tableish(response_body, row_selector, column_selectors)
    end

    def _tableish(html, row_selector, column_selectors)
      doc = Nokogiri::HTML(html)
      doc.search(row_selector).map do |row|
        cells = case(column_selectors)
        when String
          row.search(column_selectors)
        when Proc
          column_selectors.call(row)
        end
        cells.map do |cell|
          cell.text.strip
        end
      end
    end
  end
end
