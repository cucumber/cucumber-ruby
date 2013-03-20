module Cucumber
  class Unit
    def initialize(feature_element, step_collection)
      @feature_element = feature_element
      @step_collection = step_collection
    end

    def step_count
      @step_collection.length
    end

    def accept(visitor)
      visitor.visit_feature_element(@feature_element)
    end
  end
end
