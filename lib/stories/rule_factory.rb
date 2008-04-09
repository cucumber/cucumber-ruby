module Stories
  # Translates from "user" rules to Treetop rules
  class RuleFactory
    # Translates +step_expression+ to a Treetop rule body
    def rule_for(step_expression)
      "'I was ' word ' and ' word"
    end
  end
end