require 'cucumber/term/banner'

describe Cucumber::Term::Banner do
  include Cucumber::Term::Banner

  context '.display_banner' do
    let(:io) { StringIO.new }

    context 'when a string is provided' do
      it 'outputs a nice banner to IO' do
        display_banner('Oh, this is a banner', io)
        io.rewind
        expect(io.read).to eq([
          "\e[36m┌──────────────────────┐\e[0m",
          "\e[36m│\e[0m Oh, this is a banner \e[36m│\e[0m",
          "\e[36m└──────────────────────┘\e[0m\n"
        ].join("\n"))
      end

      it 'supports multi-lines' do
        display_banner("Oh, this is a banner\nwhich spreads on\nmultiple lines", io)
        io.rewind
        expect(io.read).to eq([
          "\e[36m┌──────────────────────┐\e[0m",
          "\e[36m│\e[0m Oh, this is a banner \e[36m│\e[0m",
          "\e[36m│\e[0m which spreads on     \e[36m│\e[0m",
          "\e[36m│\e[0m multiple lines       \e[36m│\e[0m",
          "\e[36m└──────────────────────┘\e[0m\n"
        ].join("\n"))
      end
    end

    context 'when an array is provided' do
      it 'outputs a nice banner with each item on a line' do
        display_banner(
          [
            'Oh, this is a banner',
            'It has two lines'
          ],
          io
        )
        io.rewind
        expect(io.read).to eq(
          [
            "\e[36m┌──────────────────────┐\e[0m",
            "\e[36m│\e[0m Oh, this is a banner \e[36m│\e[0m",
            "\e[36m│\e[0m It has two lines     \e[36m│\e[0m",
            "\e[36m└──────────────────────┘\e[0m\n"
          ].join("\n")
        )
      end

      context 'when specifying spans' do
        it 'can render special characters inside the lines' do
          display_banner(
            [
              'Oh, this is a banner',
              ['It has ', ['two', :bold, :blue], ' lines']
            ],
            io
          )

          io.rewind
          expect(io.read).to eq(
            [
              "\e[36m┌──────────────────────┐\e[0m",
              "\e[36m│\e[0m Oh, this is a banner \e[36m│\e[0m",
              "\e[36m│\e[0m It has \e[34m\e[1mtwo\e[0m\e[0m lines     \e[36m│\e[0m",
              "\e[36m└──────────────────────┘\e[0m\n"
            ].join("\n")
          )
        end
      end
    end
  end
end
