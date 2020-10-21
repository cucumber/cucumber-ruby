require 'stringio'
require 'uri'
require 'cucumber/formatter/url_reporter'

module Cucumber
  module Formatter
    describe URLReporter do
      let(:io) { StringIO.new }

      subject { URLReporter.new(io) }

      context '#report' do
        it 'displays the provided string' do
          banner = [
            '┌──────────────────────────────────────────────────────────────────────────┐',
            '│ View your Cucumber Report at:                                            │',
            '│ https://reports.cucumber.io/reports/<some-random-uid>                    │',
            '│                                                                          │',
            '│ This report will self-destruct in 24h unless it is claimed or deleted.   │',
            '└──────────────────────────────────────────────────────────────────────────┘'
          ].join("\n")
          subject.report(banner)

          io.rewind
          expect(io.read).to eq("#{banner}\n")
        end
      end
    end
  end
end
