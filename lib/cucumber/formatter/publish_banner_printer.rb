# frozen_string_literal: true

require 'cucumber/term/banner'

module Cucumber
  module Formatter
    class PublishBannerPrinter
      include Term::Banner

      def initialize(configuration)
        configuration.on_event :test_run_finished do |_event|
          display_banner(
            [
              [
                'Share your Cucumber Report with your team at ',
                ['https://reports.cucumber.io', :cyan, :bold]
              ],
              '',
              [
                'Command line option:    ',
                ['--publish', :cyan]
              ],
              [
                'Environment variable:   ',
                ['CUCUMBER_PUBLISH_ENABLED=true', :cyan]
              ],
              '',
              [
                'More information at ',
                ['https://reports.cucumber.io/docs/cucumber-ruby', :cyan]
              ],
              '',
              [
                'To disable this message, specify ',
                ['CUCUMBER_PUBLISH_QUIET=true', :dark],
                ' or use the '
              ],
              [
                ['--publish-quiet', :dark],
                ' option. You can also add this to your ',
                ['cucumber.yml:', :dark]
              ],
              'default: --publish-quiet'
            ],
            configuration.error_stream
          )
        end
      end
    end
  end
end
