module Webrat
  class Table < Element
    def self.xpath_search
      ".//table"
    end

    # Converts this Table element into a 2-dimensional array of String where each cell
    # represents the inner_html of the <td> and <th> elements. The number of columns is
    # determined by the number of cells in the first row.
    def to_a
      col_count = nil
      Webrat::XML.css_search(@element, 'tr').map do |row|
        cols = Webrat::XML.css_search(row, 'th,td')
        col_count ||= cols.length
        cols[0...col_count].map do |col|
          col.inner_html
        end
      end
    end
  end
  
  module Locators
    class TableLocator < Locator
      def locate
        Table.load(@session, table_element)
      end

      def table_element
        table_elements.detect do |table_element|
          matches_id?(table_element) ||
          matches_css_selector?(table_element)
        end
      end

      def matches_id?(table_element)
        Webrat::XML.attribute(table_element, "id") == @value.to_s
      end

      def matches_css_selector?(table_element)
        Webrat::XML.css_at(@dom, @value)
      end

      def table_elements
        Webrat::XML.xpath_search(@dom, *Table.xpath_search)
      end

      def error_message
        "Could not find table matching '#{@value}'"
      end
    end

    # Returns a Table element located by +id_or_selector+, which can
    # be a DOM id or a CSS selector.
    def table_at(id_or_selector)
      TableLocator.new(@session, dom, id_or_selector).locate!
    end
  end
  
  module Methods
    delegate_to_session :table_at
  end
  
  class Session
    def_delegators :current_scope, :table_at
  end
end
