require 'cucumber/step_mother'

module Cucumber
  def self.configure
    yield StepMother
  end
end
