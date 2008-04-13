module Cucumber
  class StepMother
    def initialize
      @steps = {}
    end

    def step(step_expression, &block)
      @steps[step_expression] = block
    end
  end
end