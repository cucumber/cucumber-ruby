# frozen_string_literal: true

require 'rake/dsl_definition'

require_relative '../cli/main'

module Cucumber
  module Rake
    class InProcessCucumberRunner
      include ::Rake::DSL if defined?(::Rake::DSL)

      attr_reader :args

      def initialize(libs, cucumber_opts, feature_files)
        raise 'libs must be an Array when running in-process' unless libs.instance_of? Array

        libs.reverse_each { |lib| $LOAD_PATH.unshift(lib) }
        @args = (cucumber_opts + feature_files).flatten.compact
      end

      def run
        failure = Cucumber::Cli::Main.execute(args)
        raise 'Cucumber failed' if failure
      end
    end
  end
end
