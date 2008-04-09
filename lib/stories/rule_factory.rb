module Stories
  # Translates from "user" rules to Treetop rules
  class RuleFactory
    # Translates +step_expression+ to a Treetop rule body
    def rule_for(step_expression)
      s = StringScanner.new(step_expression)
      rule = ""
      while !s.eos?
        if t = s.scan(/[^\$]*/)
          rule << "'#{t}'" 
        end
        if t = s.scan(/[\$]\w*/)
          rule << " word " 
        end
      end
      rule.strip
    end
  end
end