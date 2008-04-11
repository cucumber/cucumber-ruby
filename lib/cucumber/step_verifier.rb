module Cucumber
  # Verifies that steps can be matched without ambiguity.
  class StepVerifier < Visitor
    def initialize(steps)
      @steps = steps
    end
    
    def visit_step(step)
      @steps.verify_step(step.sentence_line.text_value)
    end
  end
end
