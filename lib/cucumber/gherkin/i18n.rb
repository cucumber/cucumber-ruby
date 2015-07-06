module Cucumber
  module Gherkin
    module I18n
      class << self
        def code_keyword_for(gherkin_keyword)
          gherkin_keyword.gsub(/[\s',!]/, '').strip
        end
      end
    end
  end
end
