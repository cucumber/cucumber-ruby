module Cucumber
  # Base class for Treetop nodes that know how to accept
  # a visitor.
  class AcceptingNode < Treetop::Runtime::SyntaxNode
    def self.visit_method
      @visit_method ||= ("visit_" + name.gsub(/Cucumber::(.*)/, '\1').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').downcase).to_sym
    end
    
    # Calls #accept_<underscored> on +visitor+, where <undersocored>
    # is the name of the class as underscore. For example, a
    # Cucumber::FooBar class would call #visit_foo_bar on the +visitor+.
    def accept(visitor)
      visitor.send(self.class.visit_method, self)
    end
  end
  
  class Story < AcceptingNode
    def scenarios
      scenario_nodes.elements
    end
  end
  
  class Header < AcceptingNode
  end

  class Scenario < AcceptingNode
    def steps
      step_nodes.elements
    end
  end

  class Step < AcceptingNode
  end

  # Base visitor for Story trees
  class Visitor
    def visit_story(story)
      story.scenarios.each { |scenario| scenario.accept(self) }
    end
    
    def visit_scenario(scenario)
      scenario.steps.each { |step| step.accept(self) }
    end
    
    def visit_step(step)
    end
  end
end
