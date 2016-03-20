require 'cucumber/events'
require 'cucumber/formatter/event_stream'
require 'cucumber/configuration'
require 'stringio'
require 'json'

module Cucumber
  describe Formatter::EventStream do
    let(:io) { StringIO.new }
    let(:config) { Cucumber::Configuration.new.with_options(out_stream: io) }

    it "repeats the Gherkin source back in a GherkinSourceRead event" do
      expected_source = %{Feature: A
  Scenario: B}
      formatter = Formatter::EventStream.new(config)
      config.notify Events::GherkinSourceRead.new('path/to/the.feature', expected_source)
      output = JSON.parse(io.string.lines[0])
      expect(output["source"]).to eq expected_source
      expect(output["event"]).to eq "GherkinSourceRead"
    end
  end
end
