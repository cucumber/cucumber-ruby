require 'cucumber/configuration'
require 'cucumber/formatter/console_counts'

module Cucumber
  module Formatter
    describe ConsoleCounts do
      it 'works for zero' do
        config = Configuration.new
        counts = ConsoleCounts.new(config)
        expect(counts.to_s).to eq "0 scenarios\n0 steps"
      end
    end
  end
end
