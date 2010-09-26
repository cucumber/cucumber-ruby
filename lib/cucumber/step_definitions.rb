require 'json'
module Cucumber
  class StepDefinitions
    def to_json
      { :hello => 'world' }.to_json
    end
  end
end