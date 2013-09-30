module Cucumber
  # The class which is responsible for default directory structure
  class SkeletonCreator
    def self.run()
        require 'FileUtils' unless defined?(FileUtils)
        FileUtils.mkdir_p 'features/step_definitions'
        FileUtils.mkdir_p 'features/support'
        FileUtils.touch 'cucumber.yml'
        FileUtils.touch 'features/support/env.rb'
    end
  end
end
