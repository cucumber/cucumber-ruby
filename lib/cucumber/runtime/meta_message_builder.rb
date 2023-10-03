# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/ci_environment'

module Cucumber
  class Runtime
    # Builder to instantiate a Cucumber::Messages::Meta message filled-in with
    # the runtime meta-data:
    # - protocol version: the version of the Cucumber::Messages protocol
    # - implementation: the name and version of the implementation (e.g. cucumber-ruby 8.0.0)
    # - runtime: the name and version of the runtime (e.g. ruby 3.0.1)
    # - os: the name and version of the operating system (e.g. linux 3.13.0-45-generic)
    # - cpu: the name of the CPU (e.g. x86_64)
    # - ci: information about the CI environment if any, including:
    #   - name: the name of the CI environment (e.g. Jenkins)
    #   - url: the URL of the CI environment (e.g. https://ci.example.com)
    #   - build_number: the build number of the CI environment (e.g. 123)
    #   - git: the git information of the CI environment if any
    #     - remote: the remote of the git repository (e.g. git@github.com:cucumber/cucumber-ruby.git)
    #     - revision: the revision of the git repository (e.g. abcdef)
    #     - branch: the name of the git branch (e.g. main)
    #     - tag: the name of the git tag (e.g. v1.0.0)
    class MetaMessageBuilder
      class << self
        # Builds a Cucumber::Messages::Meta filled-in with the runtime meta-data
        #
        # @param [env] environment data from which the CI information will be
        #  retrieved (default ENV). Can be used to mock the environment for
        #  testing purpose.
        #
        # @return [Cucumber::Messages::Meta] the meta message
        #
        # @see Cucumber::Runtime::MetaMessageBuilder
        #
        # @example
        # Cucumber::Runtime::MetaMessageBuilder.build_meta_message
        #
        def build_meta_message(env = ENV)
          Cucumber::Messages::Meta.new(
            protocol_version: protocol_version,
            implementation: implementation,
            runtime: runtime,
            os: os,
            cpu: cpu,
            ci: ci(env)
          )
        end

        private

        def protocol_version
          Cucumber::Messages::VERSION
        end

        def implementation
          Cucumber::Messages::Product.new(
            name: 'cucumber-ruby',
            version: Cucumber::VERSION
          )
        end

        def runtime
          Cucumber::Messages::Product.new(
            name: RUBY_ENGINE,
            version: RUBY_VERSION
          )
        end

        def os
          Cucumber::Messages::Product.new(
            name: RbConfig::CONFIG['target_os'],
            version: Sys::Uname.uname.version
          )
        end

        def cpu
          Cucumber::Messages::Product.new(
            name: RbConfig::CONFIG['target_cpu']
          )
        end

        def ci(env)
          ci_data = Cucumber::CiEnvironment.detect_ci_environment(env)
          return nil unless ci_data

          Cucumber::Messages::Ci.new(
            name: ci_data[:name],
            url: ci_data[:url],
            build_number: ci_data[:buildNumber],
            git: git_info(ci_data)
          )
        end

        def git_info(ci_data)
          return nil unless ci_data[:git]

          Cucumber::Messages::Git.new(
            remote: ci_data[:git][:remote],
            revision: ci_data[:git][:revision],
            branch: ci_data[:git][:branch],
            tag: ci_data[:git][:tag]
          )
        end
      end
    end
  end
end
