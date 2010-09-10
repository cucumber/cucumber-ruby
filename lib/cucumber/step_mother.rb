require 'cucumber/runtime'

module Cucumber
  class StepMother < Runtime
    def initialize(*args)
      warn("StepMother has been deprecated and will be gently put to sleep before the next release. Please use Runtime instead.")
      super
    end
  end
end