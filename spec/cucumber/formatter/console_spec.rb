require 'cucumber/configuration'
require 'cucumber/formatter/console'

module Cucumber
  module Formatter
    describe Console do
      include Console
      it 'indents when padding is positive' do
        res = indent('a line', 2)
        expect(res).to eq '  a line'
      end

      it 'indents when padding is negative' do
        res = indent('  a line', -1)
        expect(res).to eq ' a line'
      end

      it 'handles excessive negative indentation properly' do
        res = indent('  a line', -10)
        expect(res).to eq 'a line'
      end
    end
  end
end
