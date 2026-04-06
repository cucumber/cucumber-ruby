# frozen_string_literal: true

require 'cucumber/term/banner'

RSpec.describe Cucumber::Term::Banner do
  include described_class

  describe '.display_banner' do
    let(:io) { StringIO.new }

    context 'when a string is provided' do
      it 'outputs a nice banner to IO surrounded by a bold green border' do
        display_banner('Oh, this is a banner', io)
        io.rewind
        expect(io.read).to eq(<<~BANNER)
          \e[1m\e[32m┌──────────────────────┐\e[0m\e[0m
          \e[1m\e[32m│\e[0m\e[0m Oh, this is a banner \e[1m\e[32m│\e[0m\e[0m
          \e[1m\e[32m└──────────────────────┘\e[0m\e[0m
        BANNER
      end

      it 'supports multi-lines' do
        display_banner("Oh, this is a banner\nwhich spreads on\nmultiple lines", io, [])
        io.rewind
        expect(io.read).to eq(<<~BANNER)
          ┌──────────────────────┐
          │ Oh, this is a banner │
          │ which spreads on     │
          │ multiple lines       │
          └──────────────────────┘
        BANNER
      end
    end

    context 'when an array is provided' do
      it 'outputs a nice banner with each item on a line' do
        display_banner(['Oh, this is a banner', 'It has two lines'], io, [])
        io.rewind
        expect(io.read).to eq(<<~BANNER)
          ┌──────────────────────┐
          │ Oh, this is a banner │
          │ It has two lines     │
          └──────────────────────┘
        BANNER
      end

      it 'can render special characters inside the lines' do
        display_banner(['Oh, this is a banner', ['It has ', ['two', :bold, :blue], ' lines']], io, [])
        io.rewind
        expect(io.read).to eq(<<~BANNER)
          ┌──────────────────────┐
          │ Oh, this is a banner │
          │ It has \e[34m\e[1mtwo\e[0m\e[0m lines     │
          └──────────────────────┘
        BANNER
      end
    end

    context 'with custom borders' do
      it 'process the border with the provided attributes' do
        display_banner('this is a banner', io, %i[bold blue])

        io.rewind
        expect(io.read).to eq(<<~BANNER)
          \e[34m\e[1m┌──────────────────┐\e[0m\e[0m
          \e[34m\e[1m│\e[0m\e[0m this is a banner \e[34m\e[1m│\e[0m\e[0m
          \e[34m\e[1m└──────────────────┘\e[0m\e[0m
        BANNER
      end
    end
  end
end
