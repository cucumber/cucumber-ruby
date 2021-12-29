require 'cucumber/messages'
require 'cucumber/ci_environment'

module Cucumber
  class Runtime
    class MetaMessageBuilder
      class << self
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
