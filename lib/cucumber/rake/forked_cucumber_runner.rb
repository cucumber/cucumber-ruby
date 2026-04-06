# frozen_string_literal: true

require 'rake/dsl_definition'

module Cucumber
  module Rake
    class ForkedCucumberRunner # :nodoc:
      include ::Rake::DSL if defined?(::Rake::DSL)

      def initialize(libs, cucumber_bin, cucumber_opts, bundler, feature_files)
        @libs          = libs
        @cucumber_bin  = cucumber_bin
        @cucumber_opts = cucumber_opts
        @bundler       = bundler
        @feature_files = feature_files
      end

      def load_path
        [format('"%<path>s"', path: @libs.join(File::PATH_SEPARATOR))]
      end

      def quoted_binary(cucumber_bin)
        [format('"%<path>s"', path: cucumber_bin)]
      end

      def use_bundler
        @bundler.nil? ? File.exist?('./Gemfile') && bundler_gem_available? : @bundler
      end

      def bundler_gem_available?
        Gem::Specification.find_by_name('bundler')
      rescue Gem::LoadError
        false
      end

      def cmd
        if use_bundler
          [
            Cucumber::RUBY_BINARY, '-S', 'bundle', 'exec', 'cucumber',
            @cucumber_opts, @feature_files
          ].flatten
        else
          [
            Cucumber::RUBY_BINARY, '-I', load_path,
            quoted_binary(@cucumber_bin), @cucumber_opts, @feature_files
          ].flatten
        end
      end

      def run
        sh cmd.join(' ') do |ok, res|
          exit res.exitstatus unless ok
        end
      end
    end
  end
end
