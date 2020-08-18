require 'stringio'
require 'uri'
require 'cucumber/formatter/url_reporter'

module Cucumber
  module Formatter
    describe URLReporter do
      let(:io) { StringIO.new }

      subject { URLReporter.new(io) }

      context '#report' do
        it 'prints the corresponding reports.cucumber.io URL' do
          subject.report('https://cucumber-messages-app-s3bucket-1rakuy67mtnt0.s3.eu-west-3.amazonaws.com/reports/8519cb24-d177-40f8-8484-3237532f7772?Content-Type=application%2Fx-ndjson&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAWE4HTFKNYESY7WHP%2F20200723%2Feu-west-3%2Fs3%2Faws4_request&X-Amz-Date=20200723T113756Z&X-Amz-Expires=900&X-Amz-Security-Token=IQoJb3JpZ2luX2VjELz%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCWV1LXdlc3QtMyJHMEUCIFBFzWgBcicdoOzqtjzFirjZfWmbGwj8kaYZ9PVUSrjaAiEAj9r3UFYpYTTQ40bomj3k02LyOKm3pBkhzpi7FtqCL3Qq8wEIdRABGgw0MjI4MDE3NzkzNTUiDDhfco779UaJWFc58irQAXw1p%2FLDYm2Rvw22Kv%2F8KRVdyl%2FvqQNwwfqqvdxirMRYuIp4UjznQazeybIMc%2F4QVNNsTRosHMCWa%2BY8nTWKg5oHyUYJwAES4dz9ZF%2BJEd0TODTJBgJ%2BrzIuIkT0Gfi%2BxZNbsjiXj%2FcSJ2YCK6RthGujnG744I9%2FTH5Zd3CGiCDcp7IvLNwPMaQzVim6aCwL98Xa4FRH1GYCV9X5AUZg%2BA4Cq5o48isX9J3NwwimIzYcQAfObnCtnwK92k5X9pwQVN9n5zKX5y6mjDVSrqKnYWgwk%2B3l%2BAU64AHQAvu4lxx9WknuN%2BZE03mVPghXZtOBQtL6TYC4IpWAPYbFLrYOO%2Fykqbtac1DL2zyaJbknbasInHapRbRiCfZVnc%2BDTRzUxIGr2Fwi4ElkHezqKvdV06cwaZBxTvNNYgj%2FA%2BwgRRRHOs03yu%2FsbIn2FOZmmTCyjRMU9i4Bz1AGlCKZDtQUye1Iv0RC3ngo6yx3QwCCRX9DZIuGg0tfGAwu82LdCkEvwy05seepyz9vjbO8cTmAUOTWzHlkLKF86px%2FJ8dDJmlVWaI%2BwCIIurOflmtQyMtjgUaMC5pjK3oRIg%3D%3D&X-Amz-Signature=df70b576e319e3fc0ed86118fe12ef2d7910a83b1f3ad944ccfaf4db30ed1d49&X-Amz-SignedHeaders=host')

          io.rewind
          expect(io.read).to eq([
            "\e[36m┌──────────────────────────────────────────────────────────────────────────┐\e[0m",
            "\e[36m│\e[0m View your Cucumber Report at:                                            \e[36m│\e[0m",
            "\e[36m│\e[0m \e[4m\e[1m\e[36mhttps://reports.cucumber.io/reports/8519cb24-d177-40f8-8484-3237532f7772\e[0m\e[0m\e[0m \e[36m│\e[0m",
            "\e[36m│\e[0m                                                                          \e[36m│\e[0m",
            "\e[36m│\e[0m \e[1m\e[32mThis report will self-destruct in 24h unless it is claimed or deleted.\e[0m\e[0m   \e[36m│\e[0m",
            "\e[36m└──────────────────────────────────────────────────────────────────────────┘\e[0m",
            ''
          ].join("\n"))
        end
      end
    end
  end
end
