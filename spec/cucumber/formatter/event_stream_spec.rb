require 'cucumber/events'
require 'cucumber/formatter/event_stream'
require 'cucumber/configuration'
require 'stringio'
require 'json'

module Cucumber
  describe Formatter::EventStream do
    let(:io) { StringIO.new }
    let(:config) { Cucumber::Configuration.new.with_options(out_stream: io) }
    let(:output) { JSON.parse(io.string.lines[0]) }
    let(:formatter) { Formatter::EventStream.new(config) }

    before { formatter }

    it "repeats the Gherkin source back in a GherkinSourceRead event" do
      source = %{Feature: A
  Scenario: B}
      config.notify :gherkin_source_read, 'path/to/the.feature', source
      expect(output["source"]).to eq source
      expect(output["event"]).to eq "GherkinSourceRead"
      expect(output["id"]).to eq "path/to/the.feature:1"
    end
  end
end
